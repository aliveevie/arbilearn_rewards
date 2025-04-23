// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract MockPriceFeed {
    int256 private price;

    constructor(int256 _initialPrice) {
        price = _initialPrice;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80,
            int256 answer,
            uint256,
            uint256,
            uint80
        )
    {
        return (0, price, 0, 0, 0);
    }

    function setPrice(int256 _newPrice) external {
        price = _newPrice;
    }
}
