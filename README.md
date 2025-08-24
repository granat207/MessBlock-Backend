# MessBlock

MessBlock is a decentralized messaging protocol written in Solidity. It provides both **private chats** and **group chats** functionality, enabling users to create chats, exchange messages, and manage groups directly on-chain.

## 📚 Contracts

The project is structured into three contracts for modularity:

* **MessBlockChats** → Handles private 1-to-1 chats (create chat and send messages).
* **MessBlockGroups** → Handles group functionalities (create/join/leave groups and send messages).
* **MessBlock** → Main contract inheriting from `MessBlockChats` and `MessBlockGroups`.

## 🛠 Features

* Create and manage **private chats**
* Send **messages**
* Create, join, and leave **groups**
* Send  **group messages**
* Event logging for group creation, deletion, and membership changes
* Custom errors for precise reverts

## 🧪 Tests

This project uses **[Foundry](https://book.getfoundry.sh/)** for testing.

Tests are located in:

* `test/MessBlockChats.t.sol`
* `test/MessBlockGroups.t.sol`

Run tests with:

```bash
forge test
```

## ⚙️ Requirements

* [Foundry](https://book.getfoundry.sh/getting-started/installation) installed (`forge`, `cast`)
* Solidity ^0.8.7

## 🚀 Quick Start

Clone the repository and build the contracts:

```bash
git clone https://github.com/granat207/MessBlock-Backend.git
cd MessBlock-Backend
forge build
```

Run tests:

```bash
forge test
```

## 📄 License

This project is licensed under the **MIT License**.
