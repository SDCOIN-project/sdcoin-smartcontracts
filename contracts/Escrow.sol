pragma solidity ^0.5.0;

import "./SDC.sol";
import "./LUV.sol";
import "./Swap.sol";

import "@openzeppelin/contracts/ownership/Ownable.sol";

/** @title Escrow contract. Has ali-pay functionality
    Stores information about product such as id, price
    Used as storage for LUV, which can be withdrawed by contract owner
    Accepts payments in SDC, converts them to LUV and stores them
 */
contract Escrow is Ownable {
    /// @notice product id
    uint32 public id;
    /// @notice product price
    uint256 public price;

    /** @notice Emits on payment
        @param _sender - account, which buys product
        @param _id - product id
        @param _priceSDC - price in SDC
        @param _priceLUV - price in LUV
     */
    event Payment(address indexed _sender, uint32 _id, uint256 _priceSDC, uint256 _priceLUV);

    /// @dev deployed SDC contract
    SDC private _sdc;
    /// @dev deployed LUV contract
    LUV private _luv;
    /// @dev deployed Swap contract
    Swap private _swap;

    /** @dev amount of gas which is near the amount of gas spent in one payment
        Used to compensate gas, which user spends on one payment
     */
    uint256 constant paymentGas = 200000;

    /// @dev Checks that passed price is not zero
    modifier priceNotZero(uint256 _price) {
        require(_price != 0, "Price can't be 0");
        _;
    }

    /**
        @notice Constructs instance of escrow contract
        @param _owner - owner of escrow (retailer)
        @param _id - id of product
        @param _price - price of product
        @param _swapAddress - address of Swap contract
     */
    constructor(address _owner, uint32 _id, uint256 _price, address _swapAddress)
    public payable priceNotZero(_price) {
        _swap = Swap(_swapAddress);
        _sdc = SDC(_swap.sdc());
        _luv = LUV(_swap.luv());

        id = _id;
        price = _price;

        transferOwnership(_owner);
    }

    /// @notice Updates price of product
    /// Can be called only by contract owner
    function updatePrice(uint256 _newPriceLUV) external
    onlyOwner priceNotZero(_newPriceLUV) {
        price = _newPriceLUV;
    }

    /// @notice Counts amount of SDC which is necessary to buy given amount of product
    /// @dev Calls swap contract to get estimation, cause swap contract stores current exchange rate
    function getPriceSDC() public view returns(uint256) {
        return _swap.countSDCFromLUV(price);
    }

    /** @notice Pays SDC for product
        Emits event `Payment` on successful payment
        @param _from - address of account which buys product
        @param _sig - signature to verify account (_from)
        Payment steps:
        1. Checks passed signature
        2. Transfers SDC to Escrow contract
        3. Swaps SDC to LUV via Swap contract
        4. Returns gas, which spent in method
        @dev To make valid payments you need to create valid signature
        Signature creation described in SigVerifier.sol
        Signature allows to approve necessary sum for escrow account
     */
    function payment(address _from, bytes calldata _sig)
    external {
        require(address(this).balance >= paymentGas * tx.gasprice,
                "Insufficient ether to return gas");

        uint256 neededSDC = _swap.countSDCFromLUV(price);

        uint256 balance = _sdc.balanceOf(_from);
        require(balance >= neededSDC, "Insufficient funds for payment");

        _sdc.approveSig(neededSDC, _from, address(this), _sig);
        _sdc.transferFrom(_from, address(this), neededSDC);
        _sdc.approve(address(_swap), neededSDC);
        uint256 luvAmount = _swap.swap(address(this));

        emit Payment(_from, id, neededSDC, luvAmount);
        msg.sender.transfer(paymentGas * tx.gasprice);
    }

    /// @notice Withdraws all LUVs to owner (retailer)
    /// Can be called only by contract owner
    function withdraw() external onlyOwner {
        _luv.transfer(owner(), _luv.balanceOf(address(this)));
    }

    /// @notice Fallback function to accept ether
    function () external payable {
        require(msg.data.length == 0, "Fallback function only accepts ether");
    }

    /// @notice Withdraws all ETH to owner (retailer)
    /// Can be called only by contract owner
    function withdrawEth() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
}
