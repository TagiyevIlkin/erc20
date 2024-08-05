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
    function transfer(address to, uint tokens ) public  override returns(bool success){
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

    
    function transferFrom(address from, address to, uint tokens) public override  returns (bool success){

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