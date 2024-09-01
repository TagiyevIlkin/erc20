This Solidity program defines two smart contracts: Cryptos and CryptosICO, which implement an ERC-20 token and an Initial Coin Offering (ICO) for that token, respectively.

Cryptos Contract
The Cryptos contract is an ERC-20 compliant token contract with the following key features:

  Token Details: The token is named "Cryptos" with the symbol "CRPT" and has no decimal places.
  Supply Management: A total supply of 1,000,000 tokens is created at deployment, all of which are assigned to the contract deployer (the "founder").
  Token Transfers: Implements functions for checking balances (balanceOf), transferring tokens (transfer), approving token allowances (approve), and transferring tokens on behalf of 
  others (transferFrom).
  Events: Emits Transfer and Approval events for tracking token transactions and approvals.

CryptosICO Contract
The CryptosICO contract extends the Cryptos contract and facilitates the ICO for the "Cryptos" token. Key features of the CryptosICO contract include:

  Administrative Controls: Allows an admin (typically the contract deployer) to manage the state of the ICO, including starting, halting, and resuming the sale.
  ICO Parameters: Sets the token price at 0.001 ETH per token, a hard cap of 300 ETH, a minimum investment of 0.1 ETH, and a maximum investment of 5 ETH.
  ICO Timeline: Specifies the sale start time, end time (one week after start), and the token trade start time (one week after the sale ends).
  Investment Functionality: Investors can purchase tokens during the ICO period, provided they meet the minimum and maximum investment thresholds. The ether received from investments is 
  transferred to a deposit address.
  State Management: Maintains the state of the ICO (beforeStart, running, afterEnd, halted) and includes functions to determine and change the current state.
  Token Trading Restrictions: Prevents the transfer or trading of tokens until the specified trading start time has been reached.
  Burn Functionality: Provides a function to burn (destroy) any remaining unsold tokens after the ICO ends.

Additional Features
  Modifier: onlyAdmin restricts access to certain functions to the contract administrator.
  Events: The contract emits an Invest event whenever a user invests in the ICO.
  Fallback Function: Implements a receive function to handle direct ether transfers to the contract, automatically converting them to token purchases.

This contract is designed to manage an ERC-20 token sale in a controlled and secure manner, with built-in mechanisms for managing investments, token transfers, and post-ICO token burning.
