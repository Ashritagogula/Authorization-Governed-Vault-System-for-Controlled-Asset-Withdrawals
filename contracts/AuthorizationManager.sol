// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract AuthorizationManager is Ownable {
    using ECDSA for bytes32;

    mapping(bytes32 => bool) public authorizationUsed;

    event AuthorizationConsumed(
        bytes32 indexed authorizationId,
        address indexed vault,
        address indexed recipient,
        uint256 amount
    );

    constructor(address admin) Ownable(admin) {}

    function verifyAuthorization(
        address vault,
        address recipient,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) external returns (bool) {
        bytes32 authorizationId = keccak256(
            abi.encode(
                vault,
                block.chainid,
                recipient,
                amount,
                nonce
            )
        );

        require(!authorizationUsed[authorizationId], "Authorization already used");

        bytes32 messageHash = MessageHashUtils.toEthSignedMessageHash(
            authorizationId
        );

        address signer = ECDSA.recover(messageHash, signature);
        require(signer == owner(), "Invalid authorization signature");

        authorizationUsed[authorizationId] = true;

        emit AuthorizationConsumed(
            authorizationId,
            vault,
            recipient,
            amount
        );

        return true;
    }
}
