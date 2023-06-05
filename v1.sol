// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccessControl {
    // Roles
    mapping(address => Role) public roles;
    
    // Permissions
    enum Permission { None, Read, Write, Execute }
    
    // Role struct
    struct Role {
        Permission read;
        Permission write;
        Permission execute;
    }
    
    // Events
    event RoleCreated(address indexed user, Permission read, Permission write, Permission execute);
    event PermissionGranted(address indexed user, Permission permission);
    event PermissionRevoked(address indexed user, Permission permission);
    
    // Modifier to check permission
    modifier hasPermission(Permission permission) {
        require(roles[msg.sender].read >= permission, "AccessControl: Insufficient permission");
        _;
    }
    
    // Function to create a new role
    function createRole(address user, Permission read, Permission write, Permission execute) external {
        require(roles[user].read == Permission.None, "AccessControl: Role already exists for user");
        roles[user] = Role(read, write, execute);
        emit RoleCreated(user, read, write, execute);
    }
    
    // Function to grant a permission to a user
    function grantPermission(address user, Permission permission) external hasPermission(Permission.Write) {
        require(roles[user].read >= permission, "AccessControl: Cannot grant higher permission than existing role");
        roles[user].read = permission;
        emit PermissionGranted(user, permission);
    }
    
    // Function to revoke a permission from a user
    function revokePermission(address user, Permission permission) external hasPermission(Permission.Write) {
        require(roles[user].read >= permission, "AccessControl: Cannot revoke higher permission than existing role");
        roles[user].read = Permission.None;
        emit PermissionRevoked(user, permission);
    }
    
    // Example function with access control
    function exampleFunction() external hasPermission(Permission.Execute) {
        // Code for the function
    }
}
