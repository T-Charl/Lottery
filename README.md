# Lottery Smart Contract

This smart contract implements a decentralized lottery system using the Ethereum blockchain. The contract utilizes Chainlink VRF (Verifiable Random Function) for generating verifiably random lottery numbers. It also supports the use of an ERC20 token as the payment method for ticket purchases and winnings. The contract is built using Solidity 0.8.20 and is deployed on the Sepolia testnet.

## Key Features

* **Lottery System:** Users can buy lottery tickets by choosing 6 numbers and paying with an ERC20 token.
* **Random Number Generation:** Chainlink VRF is used to randomly draw the winning numbers in a fair and decentralized manner.
* **Multiple Lotteries:** The contract allows for multiple rounds of lotteries, each with unique ticket numbers, winning numbers, and prize pools.
* **Commissions:** The contract takes a configurable commission on each ticket sale.
* **Winners Calculation:** The contract automatically checks if any tickets match the winning numbers and distributes the prize pool among the winners.
* **Claiming Prizes:** Winners can claim their prizes based on the total jackpot and the number of winners.


## Contract Details

1. **Dependencies**
* `OpenZeppelin`: For security (ReentrancyGuard) and ERC20 token handling (SafeERC20).
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
