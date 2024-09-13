# Lottery Smart Contract

This smart contract implements a decentralized lottery system using the Ethereum blockchain. The contract utilizes Chainlink VRF (Verifiable Random Function) for generating verifiably random lottery numbers. It also supports the use of an ERC20 token as the payment method for ticket purchases and winnings. The contract is built using Solidity 0.8.20 and is deployed on the Sepolia testnet.

## Key Features

* **Lottery System:** Users can buy lottery tickets by choosing 6 numbers and paying with an ERC20 token.
* **Random Number Generation:** Chainlink VRF is used to randomly draw the winning numbers in a fair and decentralized manner.
* **Multiple Lotteries:** The contract allows for multiple rounds of lotteries, each with unique ticket numbers, winning numbers, and prize pools.
* **Commissions:** The contract takes a configurable commission on each ticket sale.
* **Winners Calculation:** The contract automatically checks if any tickets match the winning numbers and distributes the prize pool among the winners.
* **Claiming Prizes:** Winners can claim their prizes based on the total jackpot and the number of winners.


1. **Dependencies**
* `OpenZeppelin`: For security (ReentrancyGuard) and ERC20 token handling (SafeERC20).
* `Chainlink VRF`: For generating random numbers securely.
2. **Key Variables**
* `ticketPrice`: The price for purchasing one lottery ticket (denominated in the ERC20 token).
* `serviceFee`: A percentage of the ticket price taken as a commission (3000 basis points = 30%).
* `finalNumbers`: The randomly generated winning numbers.
* `payToken`: The ERC20 token used for ticket payments and prize distribution.
3. **Lottery Structure**
* **LotteryInfo**: Stores details about each lottery round, including the status, start time, end time, winning numbers, and total payouts.
* **Ticket**: Stores information about each ticket, including the chosen numbers and the ticket owner.
4. **Status Enum**
* `Open`: Lottery is open for ticket purchase
* `Close`: Lottery is closed, no more tickets can be purchased
* `Claimable`: Winning numbers have been drawn, and prizes can be claimed

## Functions

1. **openLottery()**: Opens a new lottery round by incrementing the `currentLotteryId` and setting the lottery to the `Open` state. It also sets the jackpot amount, ticket price, and end time.

2. **buyTickets(uint[6] memory numbers)**: Allows users to buy a lottery ticket by selecting 6 numbers and transferring the ticket price (in ERC20 tokens) to the contract. A commission is deducted from the ticket price, and the remainder is added to the jackpot.

3. **closeLottery()**: Closes the current lottery round and requests random numbers from Chainlink VRF for generating the winning numbers.

4. **drawNumbers()**: Generates 6 random numbers for the lottery using the random words provided by Chainlink VRF. These numbers are checked for duplicates, and the final winning numbers are stored.

5. **countWinners(uint256 _lottoId)**: Calculates the winners by comparing each ticket's chosen numbers with the drawn winning numbers. Winners are counted and recorded.

6. **claimPrize(uint256 _lottoId)**: Allows winners to claim their prize by distributing the jackpot equally among the winners.

7. **fundContract(uint256 amount)**: Enables the owner to deposit funds (ERC20 tokens) into the contract for payouts.

8. **getBalance()**: Returns the contract's balance in ERC20 tokens.

## Deployed Contract
* Contract Address(Sepolia Testnet): 0x0cE4961136171C7FEC7e0cEac960Aecb23443dE9
* ERC20 Token Address(Sepolia Testnet): 0x1E50E567D61BBa29309A066088Ef623Ea718a956

##How to Enter the Lottery via Etherscan
This guide explains how to enter the lottery using Etherscan, as the dApp interface is still under development.

### Prerequisites
1. **MetaMask Wallet**: Ensure that you have MetaMask installed and connected to the Sepolia testnet.
2. **Sepolia Eth**: You will need some Sepolia testnet ETH to cover gas fees for transactions.
3. **ABC Lottery Token(ALT)**: The specific ERC20 token used for purchasing lottery tickets must be in your MetaMask wallet.
4. **Contract Addressess**: Have both the Lottery contract and ERC20 token contract addresses handy.

### Steps to enter the lottery
1. **Mint ALT Tokens (if needed)**
If you don't already have ALT tokens (the ERC20 token required for buying lottery tickets), you can mint some directly from the ALT token contract.
1. Go to the [ALT token contract](https://sepolia.etherscan.io/address/0x1e50e567d61bba29309a066088ef623ea718a956) on Sepolia Etherscan.
2. Navigate to the Write Contract tab and connect MetaMask to your wallet.
3. Find the `mintToOwnAddress` function.
4. Enter the amount of ALT tokens you'd like to mint (in wei). For example, to mint 100 ALT tokens, you would input       100000000000000000000 (which is 100 tokens with 18 decimals). Use the Ethereum Unit COnvertor [EUC](https://eth-converter.com/)
5. Submit the transaction and confirm it in MetaMask.
Once the transaction is confirmed, the ALT tokens will be available in your wallet.

2. **Approve ALT Tokens for the Lottery Contract**
Before purchasing tickets, you need to allow the Lottery contract to spend your ALT tokens.
1. Go to the ALT token contract on Sepolia Etherscan.
2. Navigate to the Write Contract tab and connect MetaMask.
3. Find the approve function and input the following details:
   * `**spender**`: Enter the Lottery contract's address.
   * `**amount**`: Specify the number of ALT tokens you are allowing the Lottery contract to spend (in wei). Ensure                        this amount covers your ticket purchase.
4. Submit the transaction and confirm it in MetaMask.

3. **Buy Lottery Tickets**
Once you've approved the token spending, you can buy your lottery tickets.
1. Go to the [Lottery contract](https://sepolia.etherscan.io/address/0x1e50e567d61bba29309a066088ef623ea718a956) on Sepolia Etherscan.
2. Navigate to the **Write Contract** tab and connect MetaMask.
3. Find the buyTickets(uint[6] memory numbers) function and do the following:
   * **numbers**: Enter 6 unique numbers of your choice between 1 and 49. For example: [7, 18, 29, 42, 36, 12].
4. Click "Write" to submit the transaction and confirm it in MetaMask.
After the transaction is confirmed, your ticket will be successfully entered into the lottery round.

## Viewing Your Tickets
You can check your active tickets by calling the `getTickets()` function:

1. Go to the **Read Contract** section of the Lottery contract on Etherscan.
2. Find the `getTickets` function and call it to view the tickets you’ve entered.

## Verifying Winning Numbers
After the lottery closes, you can view the winning numbers by calling the finalNumbers() function:

1. Navigate to the **Read Contract** tab on the Lottery contract.
2. Find and call the `finalNumbers()` function to see the winning numbers.

## Claiming Winnings

If your ticket matches the winning numbers, you can claim your prize by calling the claimPrize() function:

1. Navigate to the **Write Contract** tab on Etherscan.
2. Locate the `claimPrize(uint256 lotteryId)` function.
3. Input the **lotteryId** for the round you participated in, then submit the transaction.
Your prize will be transferred to your wallet if you're a winner.

## Contract Addresses

**Lottery Contract Address**: 0x0cE4961136171C7FEC7e0cEac960Aecb23443dE9
**ALT Token Contract Address**: 0x1E50E567D61BBa29309A066088Ef623Ea718a956

Make sure you have sufficient ALT tokens and Sepolia ETH to interact with the contract.
Notes

Connect to the Sepolia testnet before interacting with Etherscan.
Verify contract addresses and balances before performing transactions.



