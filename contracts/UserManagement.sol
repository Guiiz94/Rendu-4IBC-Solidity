// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserManagement {
    struct User {
        address addr;
        string username;
    }

    mapping(address => User) public users;

    event UserRegistered(address user, string username);

    function registerUser(string calldata username) external {
        require(bytes(users[msg.sender].username).length == 0, "User already registered.");
        users[msg.sender] = User(msg.sender, username);
        emit UserRegistered(msg.sender, username);
    }
}