// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Lottery is ReentrancyGuard, Ownable, VRFConsumerBaseV2 {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // ChainLink VRFv2 Subscription Settings
    VRFCoordinatorV2Interface COORDINATOR;

    uint64 private s_subscriptionId;
    address private vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
    bytes32 private keyHash = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
    uint16 private requestConfirmations = 3;
    uint32 private numWords = 6;
    uint32 private callbackGasLimit = 2500000;
    address private s_owner;

    struct RequestStatus {
        bool fulfilled;
        bool exists;
        uint[] randomWords;
    }

    mapping(uint256 => RequestStatus) public s_requests;
    uint256 public lastRequestId;

    // Lottery Settings
    IERC20 public paytoken;
    uint256 public currentLotteryId;
    uint256 public currentTicketId;
    uint256 public ticketPrice = 10 ether;
    uint256 public serviceFee = 3000; // BASIS POINTS 3000 is 30%
    uint256 public numberWinner;

    enum Status {
        Open,
        Close,
        Claimable
    }

    struct LotteryInfo {
        Status status;
        uint256 startTime;
        uint256 endTime;
        uint256 firstTicketId;
        uint256 transferJackpot;
        uint256 lastTicketId;
        uint[6] winningNumbers;
        uint256 totalPayout;
        uint256 commision;
        uint256 winnerCount;
    }

    struct Ticket {
        uint256 ticketId;
        address owner;
        uint[6] chooseNumbers;
    }

    mapping(uint256 => LotteryInfo) private _lotteries;
    mapping(uint256 => Ticket) private _tickets;
    mapping(address => mapping(uint256 => uint256[])) private _userTicketIdsPerLotteryId;
    mapping(address => mapping(uint256 => uint256)) public _winnersPerLotteryId;

    event LotteryWinnerNumber(uint256 indexed lotteryId, uint[6] finalNumber);
    event LotteryClose(uint256 indexed lotteryId, uint256 lastTicketId);
    event LotteryOpen(
        uint256 indexed lotteryId,
        uint256 startTime,
        uint256 endTime,
        uint256 ticketPrice,
        uint256 firstTicketId,
        uint256 transferJackpot,
        uint256 lastTicketId,
        uint256 totalPayout
    );

    event TicketsPurchase(
        address indexed buyer,
        uint256 indexed lotteryId,
        uint[6] chooseNumbers
    );

    constructor(uint64 subscriptionId) 
        VRFConsumerBaseV2(vrfCoordinator)
        Ownable(msg.sender) // Pass the initial owner address
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
        paytoken = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F); // DAI token address
    }

    // Open lottery function
    function openLottery() external onlyOwner nonReentrant {
        currentLotteryId++;
        currentTicketId++;
        uint256 fundJackpot = (_lotteries[currentLotteryId].transferJackpot).add(1000 ether);
        uint256 transferJackpot;
        uint256 totalPayout;
        uint256 lastTicketId;
        uint256 endTime;
        _lotteries[currentLotteryId] = LotteryInfo({
            status: Status.Open,
            startTime: block.timestamp,
            endTime: (block.timestamp).add(1 days),
            firstTicketId: currentTicketId,
            transferJackpot: fundJackpot,
            winningNumbers: [uint(0), uint(0), uint(0), uint(0), uint(0), uint(0)],
            lastTicketId: currentTicketId,
            totalPayout: 0,
            commision: 0,
            winnerCount: 0
        });
        emit LotteryOpen(
            currentLotteryId,
            block.timestamp,
            endTime,
            ticketPrice,
            currentTicketId,
            transferJackpot,
            lastTicketId,
            totalPayout
        );
    }

    // Buy tickets function
    function buyTickets(uint[6] memory numbers) public payable nonReentrant {
        uint256 walletBalance = paytoken.balanceOf(msg.sender);
        require(walletBalance >= ticketPrice, "Funds not available to complete transaction");
        paytoken.transferFrom(address(msg.sender), address(this), ticketPrice);
        // Calculate Commission Fee
        uint256 commisionFee = (ticketPrice.mul(serviceFee)).div(10000);
        // Platform commission per ticket sale
        _lotteries[currentLotteryId].commision += commisionFee;
        uint256 netEarn = ticketPrice - commisionFee;
        _lotteries[currentLotteryId].transferJackpot += netEarn;

        // Store ticket number array for the buyer
        _userTicketIdsPerLotteryId[msg.sender][currentLotteryId].push(currentTicketId);
        _tickets[currentTicketId] = Ticket({ticketId:currentTicketId, owner: msg.sender, chooseNumbers: numbers });
        currentTicketId++;
        _lotteries[currentLotteryId].lastTicketId = currentTicketId;
        emit TicketsPurchase(msg.sender, currentLotteryId, numbers);
    }

    // Close lottery function
    function closeLottery() external onlyOwner {
        require(_lotteries[currentLotteryId].status == Status.Open, "Lottery not open");
        require(block.timestamp > _lotteries[currentLotteryId].endTime, "Lottery not over");
        _lotteries[currentLotteryId].lastTicketId = currentTicketId;
        _lotteries[currentLotteryId].status = Status.Close;

        // Request Id for ChainLink VRF
        uint256 requestId;
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](numWords),
            exists: true,
            fulfilled: false
        });
        lastRequestId = requestId;
        emit LotteryClose(currentLotteryId, currentTicketId);
    }

    // Draw numbers function
    function drawNumbers() external onlyOwner nonReentrant {
        require(_lotteries[currentLotteryId].status == Status.Close, "Lottery not close");
        uint256[] memory numArray = s_requests[lastRequestId].randomWords;
        uint num1 = numArray[0] % 49;
        uint num2 = numArray[1] % 49;
        uint num3 = numArray[2] % 49;
        uint num4 = numArray[3] % 49;
        uint num5 = numArray[4] % 49;
        uint num6 = numArray[5] % 49;
        uint[6] memory finalNumbers = [num1, num2, num3, num4, num5, num6];
        for (uint i = 0; i < finalNumbers.length; i++){
            if (finalNumbers[i] == 0) {
                finalNumbers[i] = 1;
            }
        }
        _lotteries[currentLotteryId].winningNumbers = finalNumbers;
        _lotteries[currentLotteryId].status = Status.Claimable;
        emit LotteryWinnerNumber(currentLotteryId, finalNumbers);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        require(s_requests[requestId].exists, "Request not found");
        s_requests[requestId].randomWords = randomWords;
        s_requests[requestId].fulfilled = true;
    }
}
