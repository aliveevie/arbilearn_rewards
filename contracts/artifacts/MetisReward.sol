// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/access/Ownable.sol";

interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80,
        int256 answer,
        uint256,
        uint256,
        uint80
    );
}

contract TMetisRewardTestnet is Ownable {
    AggregatorV3Interface public priceFeed;

    mapping(address => bool) public whitelisted;
    mapping(address => bool) public hasClaimed;
    address[] private eligibleAddresses;

    event AddressWhitelisted(address indexed user);
    event RewardClaimed(address indexed user, uint256 amount);
    event Received(address indexed from, uint256 amount);

    constructor() {
        priceFeed = AggregatorV3Interface(0x83495fa68532b8824D9a87330fD53644D7B468CE);
    }

    function getRewardAmountInTMetis() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        return (5 * 1e18 * 1e8) / uint256(price); // 5 USD worth
    }

    function addToWhitelist(address user) external onlyOwner {
        require(!whitelisted[user], "Already whitelisted");
        whitelisted[user] = true;
        eligibleAddresses.push(user);
        emit AddressWhitelisted(user);
    }

    function getEligibleAddresses() external view returns (address[] memory) {
        return eligibleAddresses;
    }

    function claimReward() external payable  {
        require(whitelisted[msg.sender], "Not whitelisted");
        require(!hasClaimed[msg.sender], "Already claimed");

        uint256 rewardAmount = getRewardAmountInTMetis();
        require(address(this).balance >= rewardAmount, "Not enough funds");

        hasClaimed[msg.sender] = true;
        payable(msg.sender).transfer(rewardAmount);
        emit RewardClaimed(msg.sender, rewardAmount);
    }

    /// ✅ Get tMETIS balance (in wei) on the contract
    function getContractNativeBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /// ✅ Get USD equivalent of the contract’s tMETIS balance
    function getContractUsdBalance() public view returns (uint256 usdAmount) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        uint256 balance = address(this).balance;
        usdAmount = (balance * uint256(price)) / 1e26; // because: 18 (wei) + 8 (price) - 18 (USD)
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {}
}
