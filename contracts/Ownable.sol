pragma solidity ^0.5.11;

contract Ownable {
    address private _owner;
    mapping(address => bool) _whitelist;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    // modifiers

    modifier onlyOwnerOrAdmin() {
        require(isAdmin(msg.sender) || isOwner(),
                "Caller is neither owner nor admin");
        _;
    }

    modifier onlyOwner() {
        require(isOwner(), "Caller is not owner");
        _;
    }

    // owner

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function isOwner() internal view returns(bool) {
        return msg.sender == _owner;
    }

    function owner() public view returns(address) {
        return _owner;
    }

    // admins

    function addAdmin(address account) public onlyOwnerOrAdmin {
        require(account != address(0), "New admin is the zero address");
        require(!isAdmin(account), "Account is already admin");
        _whitelist[account] = true;
        emit WhitelistAdminAdded(account);
    }

    function removeAdmin(address account) public onlyOwnerOrAdmin {
        require(isAdmin(account), "Account is not admin");
        delete _whitelist[account];
        emit WhitelistAdminRemoved(account);
    }

    function isAdmin(address account) public view returns(bool) {
        return _whitelist[account];
    }
}