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
    event RoleAssigned(address indexed user, Permission read, Permission write, Permission execute);
    event RoleRevoked(address indexed user);
    event PermissionsRevoked(address indexed user);
    event RoleOwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // Circuit breaker
    bool private paused;
    
    // Modifier to check permission and contract status
    modifier hasPermission(Permission permission) {
        require(!paused, "AccessControl: Contract is paused");
        require(roles[msg.sender].read >= permission, "AccessControl: Insufficient permission");
        _;
    }
    
    // Modifier for contract owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "AccessControl: Only contract owner can invoke this function");
        _;
    }
    
    // Contract owner
    address public owner;
    
    // Constructor
    constructor() {
        owner = msg.sender;
    }
    
    // Function to create a new role
    function createRole(address user, Permission read, Permission write, Permission execute) external onlyOwner {
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
    
    // Function to assign a role to a user
    function assignRole(address user, Permission read, Permission write, Permission execute) external onlyOwner {
        roles[user] = Role(read, write, execute);
        emit RoleAssigned(user, read, write, execute);
    }
    
    // Function to revoke a role from a user
    function revokeRole(address user) external onlyOwner {
        delete roles[user];
        emit RoleRevoked(user);
    }
    
    // Function to check the permission level of a user
    function checkPermission(address user, Permission action) external view returns (Permission) {
        return roles[user].read;
    }
    
    // Function to get the role of a user
    function getRole(address user) external view returns (Role memory) {
        return roles[user];
    }
    
    // Function to update the permissions of a role
    function updateRolePermissions(address user, Permission read, Permission write, Permission execute) external onlyOwner {
        require(roles[user].read != Permission.None, "AccessControl: Role
