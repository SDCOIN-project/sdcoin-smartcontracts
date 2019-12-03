pragma solidity ^0.5.11;

/**
    @title Ownership management contract
    @notice Manages owner and admins for contract. Owner is the contract creator by default. 
    Owner can't be changed by admins. Owner can pass his ownership to another account
 */
contract Ownable {
    /// @notice owner of contract. Can be changed by owner himself via transferOwnership
    address private _owner;
    /// @notice whitelist of admins. Can be added/removed by owner and other admins
    mapping(address => bool) _whitelist;

    /// @notice Emitted when owner passes his ownership to another account
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /// @notice Emitted when new admin added to account
    event WhitelistAdminAdded(address indexed account);
    /// @notice Emitted when existing admin removed from account
    event WhitelistAdminRemoved(address indexed account);

    /// @dev Creates contract and makes msg.sender as owner of contract
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    // modifiers

    /// @notice Modifier checks if caller is owner or admin of contract
    modifier onlyOwnerOrAdmin() {
        require(isAdmin(msg.sender) || isOwner(),
                "Caller is neither owner nor admin");
        _;
    }

    /// @notice Modifier checks if caller is owner of contract
    modifier onlyOwner() {
        require(isOwner(), "Caller is not owner");
        _;
    }

    // owner

    /// @notice Transfers ownership to another account. Can be called only by owner
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /// @dev Returns true if msg.sender is owner of contract
    function isOwner() internal view returns(bool) {
        return msg.sender == _owner;
    }

    /// @notice Returns address of contract owner
    function owner() public view returns(address) {
        return _owner;
    }

    // admins

    /// @notice Adds admin to contract. Can be called by owner or admin
    function addAdmin(address account) public onlyOwnerOrAdmin {
        require(account != address(0), "New admin is the zero address");
        require(!isAdmin(account), "Account is already admin");
        _whitelist[account] = true;
        emit WhitelistAdminAdded(account);
    }

    /// @notice Removes admin from contract. Can be called by owner or admin
    function removeAdmin(address account) public onlyOwnerOrAdmin {
        require(isAdmin(account), "Account is not admin");
        delete _whitelist[account];
        emit WhitelistAdminRemoved(account);
    }

    /// @notice Returns whether account admin or not
    function isAdmin(address account) public view returns(bool) {
        return _whitelist[account];
    }
}