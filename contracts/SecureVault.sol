// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAuthorizationManager {
    function verifyAuthorization(
        address vault,
        address recipient,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) external returns (bool);
}

contract SecureVault {
    IAuthorizationManager public immutable authorizationManager;

    uint256 public totalBalance;

    event Deposit(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount, uint256 nonce);

    constructor(address authManager) {
        require(authManager != address(0), "Invalid authorization manager");
        authorizationManager = IAuthorizationManager(authManager);
    }

    receive() external payable {
        require(msg.value > 0, "Zero deposit");
        totalBalance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(
        address recipient,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) external {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Invalid amount");
        require(totalBalance >= amount, "Insufficient vault balance");

        bool authorized = authorizationManager.verifyAuthorization(
            address(this),
            recipient,
            amount,
            nonce,
            signature
        );
        require(authorized, "Authorization failed");

        // ✅ EFFECTS FIRST
        totalBalance -= amount;

        // ✅ INTERACTION AFTER
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit Withdrawal(recipient, amount, nonce);
    }
}
