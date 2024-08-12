// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


interface ERC20Interface {

    function totalSupply() external view returns (uint);
    function balanceOf(address tokenowner ) external view returns(uint balance);
    function transfer(address to, uint tokens ) external  returns(bool success);

    function allowance(address tokenOwner, address spender) external  view  returns(uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner,address indexed  spender, uint tokens);
}


contract Cryptos is ERC20Interface{

        // State variables
        string public name ="Cryptos";
        string public  symbol="CRPT";
        uint public decimals=0; //18 is most used
        uint public  override totalSupply;

        // Declare founnder address and balances mapping to store tokens
        address public founder;
        mapping (address=>uint) public  balances;
        // Includes accounts approved to withdraw from a given account
        mapping (address=> mapping (address=>uint) ) allowed;
    constructor() {
        totalSupply=1000000;
        founder=msg.sender;
        balances[founder]=totalSupply;
    }

    // balanceOf overrides method of ERC20Interface and returns balance of  tokenOwner
    function balanceOf(address tokenowner ) public   view override returns(uint balance){
    return balances[tokenowner];
    }

    // transfer overrides method of ERC20Interface and transfers token(s) from 1 account to another
    function transfer(address to, uint tokens ) public  virtual override returns(bool success){
       // Check if the sender has enough tokens to transfer
        require(balances[msg.sender]>=tokens,"Balance is insufficent");
      
        balances[to]+=tokens;
        balances[msg.sender]-=tokens;
        emit Transfer(msg.sender,to,tokens);

        return true;
    }

    function allowance(address tokenOwner, address spender) public  override  view  returns(uint remaining){
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public  override  returns (bool success){
        require(tokens>0,"tokens should be greater than 0");
        // Check if the sender has enough tokens to transfer
        require(balances[msg.sender]>=tokens,"Balance is insufficent");

        allowed[msg.sender][spender]=tokens;

        emit Approval(msg.sender, spender, tokens);
        return  true;
    }

    
    function transferFrom(address from, address to, uint tokens) public virtual override  returns (bool success){

        require(allowed[from][msg.sender]>=tokens,"Balance is insufficent");
        require(balances[from]>=tokens);

        // Decrease balances of 'from' and allowed of  sender
        balances[from]-=tokens;
        allowed[from][msg.sender]-=tokens;
        // Increase balance of 'to'
        balances[to]+=tokens;

        // Emit the event
        emit Transfer(from, to, tokens);

        return true;
    }
}


contract CryptosICO is Cryptos{
        address public admin;
        // Declare a deposit address where the ether will be send
        address payable public  deposit;
        uint tokenPrice=0.001 ether; // 1ETH = 1000 CRPT, 1CRPT = 0.001 ETH
        uint public hardCap =300 ether;
        uint public totalRaisedAmount; // in wei
        // ICO starts right away
        uint public saleStart=block.timestamp;
        // ICO ends in a week
        uint public saleEnd=block.timestamp+604800; // 604800 = a week in seconds
        // ICO will bee transferable(trade) in a week after sale ends
        uint public tokenTradeStart=saleEnd + 604800; // 604800 = a week in seconds
        // Declaring max and min inverstment 
        uint public  maxInverstment=5 ether;
        uint public  minInverstment=0.1 ether;

        // Declare ICO state
        enum State {beforeStart, running, afterEnd, halted}
        State public icoState;

        // Initialize vars through constructor
        constructor(address payable _deposit) {
            deposit=_deposit;
            admin=msg.sender;
            icoState=State.beforeStart; 
        }

        // onlyAdmin requires the sender to be admin
        modifier onlyAdmin{
            require(msg.sender==admin,"Only admin is allowed");
            _;
        }

        // halt changes the state of contract(ICO) to 'halted'
        function halt() public onlyAdmin{
            icoState=State.halted;
        }
        
        // resume changes the state of contract(ICO) to 'running'
        function resume() public onlyAdmin{
            icoState=State.running;
        }

        // changeDepositAddress changes the deposit address to new one (in case of compromisation)
        function changeDepositAddress(address payable newDeposit)public onlyAdmin{
            deposit=newDeposit;
        }

        // getCurrentState returns the current state of ICO
        function getCurrentState()public view  returns(State s){
            if (icoState == State.halted){
            return  State.halted;
            }else if(block.timestamp<saleStart){
            return  State.beforeStart;
            }else if(block.timestamp>=saleStart && block.timestamp<=saleEnd){
            return  State.running;
            }else {
               return  State.afterEnd;
            }
        }

        // Declare an Invest event
        event Invest(address investor, uint value, uint tokens);

        function invest() payable public returns(bool)   {
            // Get current ICO state
            icoState=getCurrentState();
            // Require ICO state to be running
            require(icoState==State.running,"ICO is not running");
           
            // Require value sent met minInverstment & maxInverstment conditions
            require(msg.value>=minInverstment && msg.value<=maxInverstment,"Investnment value should be between 0.1 ETH and 5 ETH");
           // increase totalRaisedAmount
            totalRaisedAmount+=msg.value;    
            require(totalRaisedAmount<=hardCap,"Total raised amount should not be more than Hard Cap");

            // Calculate how many tokens user will get
            uint tokens = msg.value / tokenPrice;

            balances[msg.sender]+=tokens; // Increase balance of sender 
            balances[founder]-=tokens;    // Decrease balance of founder 
            deposit.transfer(msg.value);  // Transfer the value to deposit address

            // Emit the event
           emit Invest(msg.sender,msg.value,tokens);

           return  true;
        }

        // Declare a built-in receive function to accept ETH if it is directly sent to contract address
        receive() external payable {
            invest();
        }

        
    // transfer overrides method of ERC20Interface and transfers token(s) from 1 account to another
    function transfer(address to, uint tokens ) public   override returns(bool success){
        // Check if the tpken can be trated
        require(block.timestamp>tokenTradeStart,"Token cannot be trated right now");
        super.transfer(to, tokens); 
        return true;
    }


    function transferFrom(address from, address to, uint tokens) public  override  returns (bool success){

        require(block.timestamp>tokenTradeStart,"Token cannot be trated right now");

        super.transferFrom(from, to, tokens);

        return true;
    }

    // burn burns the tokens(destroying tokens)
    function  burn() public  returns(bool){
        icoState=getCurrentState();
        // Require
        require(icoState==State.afterEnd,"Tokens can be burned in only after end state");
        // Reset the balance of founder to 0
        balances[founder]=0;
        return true;
    }

}