// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract getRandomness {
    
    function getRandomNumber() external view returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(msg.sender, block.prevrandao, block.timestamp)));
        return randomNumber;
    }
}

contract Lottery {
    getRandomness private randomness;
    address public manager;
    address[] public players;
    uint256 public ticketPrice;
    bool public isLotteryOpen;

    event LotteryOpened(uint256 ticketPrice, uint256 timestamp);
    event TicketPurchased(address indexed player, uint256 timestamp);
    event LotteryClosed(address winner, uint256 prizeAmount, uint256 timestamp);

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

    constructor(address _randomness, uint256 _ticketPrice) {
        randomness = getRandomness(_randomness);
        manager = msg.sender;
        ticketPrice = _ticketPrice;
        isLotteryOpen = false;
    }

    /**
     * @dev Opens the lottery for ticket purchase
     */
    function openLottery() external onlyManager {
        require(!isLotteryOpen, "Lottery is already open");
        isLotteryOpen = true;
        emit LotteryOpened(ticketPrice, block.timestamp);
    }

    /**
     * @dev Allows users to buy tickets
     */
    function buyTicket() external payable {
        require(isLotteryOpen, "Lottery is not open");
        require(msg.value == ticketPrice, "Incorrect ticket price");
        players.push(msg.sender);
        emit TicketPurchased(msg.sender, block.timestamp);
    }

    /**
     * @dev Closes the lottery and selects a winner
     */
    function closeLottery() external onlyManager {
        require(isLotteryOpen, "Lottery is not open");
        require(players.length > 0, "No players in the lottery");

        uint256 randomNumber = randomness.getRandomNumber();
        uint256 winnerIndex = randomNumber % players.length;
        address winner = players[winnerIndex];

        uint256 prizeAmount = address(this).balance;
        payable(winner).transfer(prizeAmount);

        emit LotteryClosed(winner, prizeAmount, block.timestamp);

        // Reset lottery state
        players = new address      isLotteryOpen = false;
    }

    /**
     * @dev Returns the list of players
     */
    function getPlayers() external view returns (address[] memory) {
        return players;
    }
}
