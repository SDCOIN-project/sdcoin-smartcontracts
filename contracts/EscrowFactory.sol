pragma solidity ^0.5.0;

import "./Swap.sol";
import "./Escrow.sol";

/**
    @title Escrow Factory contract
    Creates and stores escrow contracts
 */
contract EscrowFactory {
    /// @notice stores escrow contracts for each user
    mapping(address => address[]) private escrowList;

    /** @notice Emits on escrow contract creation
        @param _owner - owner of new escrow contract
        @param _escrowAddress - address of new escrow contract
        @param _escrowIndex - index of new escrow contract
     */
    event Created(address indexed _owner, address indexed _escrowAddress, uint256 _escrowIndex);

    /// @notice address of deployed Swap contract
    address public swap;

    constructor(address _swapAddress) public {
        swap = _swapAddress;
    }

    /** @notice creates escrow contract and assigns sender as
        escrow contract owner. Emits event on creation
        @param _id - escrow product id
        @param _price - escrow product price in LUV
        @return address of new contract and its index
     */
    function create(uint32 _id, uint256 _price) external payable {
        Escrow escrow = (new Escrow).value(msg.value)(msg.sender, _id, _price, swap);
        escrowList[msg.sender].push(address(escrow));
        emit Created(msg.sender, address(escrow), escrowList[msg.sender].length-1);
    }

    /// @notice returns count of escrow contracts created by _owner
    function getEscrowListCount(address _owner) external view returns(uint256) {
        return escrowList[_owner].length;
    }

    /// @notice returns escrow contract for _owner by its index
    function getEscrowByIndex(address _owner, uint256 _index) external view returns(address) {
        return escrowList[_owner][_index];
    }

    /// @notice returns all escrow contracts for _owner
    function getEscrowList(address _owner) external view returns(address[] memory) {
        return escrowList[_owner];
    }
}