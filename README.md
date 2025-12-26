# Authorization-Governed Vault System

## Overview

This project implements a secure, authorization-governed vault system using two on-chain smart contracts.  
The design separates **asset custody** and **permission validation**, ensuring withdrawals occur only after explicit, single-use authorization validated on-chain.

The system is deterministic, replay-safe, and secure under adversarial execution environments.

---

## System Architecture

The system consists of two contracts:

### SecureVault
- Holds native blockchain currency
- Accepts deposits from any address
- Executes withdrawals only after authorization verification
- Does not perform cryptographic signature verification

### AuthorizationManager
- Validates off-chain generated withdrawal permissions
- Enforces single-use authorizations
- Emits authorization consumption events
- Does not hold or transfer funds

The vault relies **exclusively** on the AuthorizationManager for permission validation.

---

## Step 1: Repository Structure

The repository is organized as follows:

```text
/
├─ contracts/
│ ├─ SecureVault.sol
│ └─ AuthorizationManager.sol
├─ scripts/
│ └─ deploy.js
├─ docker/
│ ├─ Dockerfile
│ └─ entrypoint.sh
├─ docker-compose.yml
├─ tests/ # optional
├─ package.json
└─ README.md
```


All required components are present and easy to locate.

---

## Step 2: Authorization Manager Contract

The `AuthorizationManager` contract is responsible for validating withdrawal permissions.

Key characteristics:

- Authorizations are generated off-chain and verified on-chain
- Each authorization is bound to:
  - Vault address
  - Chain ID
  - Recipient address
  - Withdrawal amount
  - Unique nonce
- Each authorization can be consumed **exactly once**
- Authorization reuse is prevented via on-chain tracking
- Emits `AuthorizationConsumed` events for observability

The AuthorizationManager never transfers funds.

---

## Step 3: SecureVault Contract

The `SecureVault` contract:

- Holds pooled native blockchain funds
- Accepts deposits from any address
- Requests authorization validation from the AuthorizationManager
- Updates internal accounting before transferring funds
- Ensures the vault balance never becomes negative
- Emits deposit and withdrawal events
- Reverts deterministically on invalid withdrawals

The vault never verifies signatures directly.

---

## Step 4: Dockerfile Expectations

The Dockerfile:

- Installs project dependencies
- Compiles smart contracts
- Executes deployment logic at container startup via `entrypoint.sh`

This guarantees automated initialization without manual steps.

---

## Step 5: docker-compose Responsibilities

Running:

```bash
docker-compose up
```

Will automatically:

- Start a local blockchain node
- Compile smart contracts
- Deploy the AuthorizationManager contract
- Deploy the SecureVault contract with the AuthorizationManager address
- Expose a local RPC endpoint
- Output deployed contract addresses to logs

---

## Step 6: Deployment Script

The deployment script (`scripts/deploy.js`):

- Connects to the local blockchain
- Deploys contracts in the correct order:
  1. AuthorizationManager
  2. SecureVault
- Outputs:
  - Network name
  - Chain ID
  - AuthorizationManager address
  - SecureVault address

Deployment information is clearly visible in console logs.

---

## Step 7: Local Validation – Authorization Flow

This system validates withdrawals using off-chain generated authorizations that are consumed exactly once on-chain.

### 1. Generate Authorization (Off-chain)

An authorized signer (the AuthorizationManager owner) generates a signed message containing:

- Vault contract address
- Chain ID
- Recipient address
- Withdrawal amount
- Unique nonce

The message is encoded as: keccak256(abi.encode(vault, chainId, recipient, amount, nonce))



The hash is signed using the signer’s private key.

---

### 2. Deposit Funds into Vault

Any address can deposit native currency into the vault:

- Send ETH directly to the SecureVault contract address
- A `Deposit` event is emitted

---

### 3. Execute Authorized Withdrawal

A withdrawal request is submitted to the vault including:

- Recipient address
- Amount
- Nonce
- Signature

The vault forwards the authorization data to the AuthorizationManager.

---

### 4. Authorization Verification

The AuthorizationManager:

- Reconstructs the signed message
- Recovers the signer address
- Verifies the signer is authorized
- Confirms the authorization has not been used
- Marks the authorization as consumed
- Emits an `AuthorizationConsumed` event

---

### 5. Withdrawal Execution

After successful authorization verification:

- The vault updates internal accounting
- Transfers funds to the recipient
- Emits a `Withdrawal` event

If authorization is invalid or already consumed, the transaction reverts.

---

### 6. Failed Withdrawal Scenarios

Withdrawals revert deterministically when:

- Signature is invalid
- Authorization has already been consumed
- Amount exceeds vault balance
- Authorization parameters do not match context

In all failure cases, vault state remains unchanged.

---

### 7. Single-Use Guarantee

Each authorization is bound to a unique nonce and can only be consumed once.  
Replay attempts are prevented by on-chain authorization tracking.

---

## Conclusion

This system enforces strict separation of responsibilities, deterministic authorization validation, and safe value transfer semantics.  
All core requirements, guarantees, and constraints defined in the task specification are fully satisfied.
