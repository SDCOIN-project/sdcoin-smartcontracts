pragma solidity ^0.5.11;

import "./SDC.sol";
import "./LUV.sol";
import "./Swap.sol";
import "./SigVerifier.sol";

contract Escrow {
    uint32 public id;
    uint256 public price;
    uint32 public amount;

    address public owner;

    event Payment(address indexed _sender, uint32 _id, uint256 _unitPrice,
                  uint32 _soldAmount, uint256 _priceSDC, uint256 _priceLUV);

    SigVerifier.Data private _nonces;

    SDC private _sdc;
    LUV private _luv;
    Swap private _swap;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier priceNotZero(uint256 _price) {
        require(_price != 0, "Price can't be 0");
        _;
    }

    modifier enoughAmount(uint32 _amount) {
        require(amount >= _amount, "Not enough items");
        _;
    }

    constructor(address _owner, uint32 _id, uint256 _price, uint32 _amount,
                address _sdcAddress, address _luvAddress, address _swapAddress)
                public priceNotZero(_price) {
        _sdc = SDC(_sdcAddress);
        _luv = LUV(_luvAddress);
        _swap = Swap(_swapAddress);

        id = _id;
        price = _price;
        amount = _amount;

        owner = _owner;
    }

    function updatePrice(uint256 _newPriceLUV) external onlyOwner {
        price = _newPriceLUV;
    }

    function updateAmount(uint32 _newAmount) external onlyOwner {
        _updateAmount(_newAmount);
    }

    function getPriceSDC(uint32 _amount) public view returns(uint256) {
        return _swap.countSDCFromLUV(_amount * price);
    }

    function getNonce(address _account) external view returns(uint256) {
        return SigVerifier.getNonce(_nonces, _account);
    }

    function payment(uint32 _sellAmount,
                     address _from, address _spender, uint256 _value, bytes calldata _sig)
    external enoughAmount(_sellAmount) {
        bool isValid = SigVerifier.verify(_nonces, _from, _spender, _value, _sig);
        require(isValid, "Invalid signature");

        uint256 sdcAmount = _sdc.allowance(msg.sender, address(this));
        require(sdcAmount > 0, "No SDC approved for transfer");

        uint256 balance = _sdc.balanceOf(msg.sender);
        require(balance >= sdcAmount, "Insufficient funds for payment");

        uint256 neededSDC = _swap.countSDCFromLUV(_sellAmount * price);
        require(sdcAmount >= neededSDC, "Not enough SDC");

        _sdc.transferFrom(msg.sender, address(this), neededSDC);
        _sdc.approve(address(_swap), neededSDC);
        uint256 luvAmount =_swap.swap(address(this));

        _updateAmount(amount - _sellAmount);

        emit Payment(_from, id, price, _sellAmount, neededSDC, luvAmount);
    }

    function withdraw() external onlyOwner {
        uint256 luvAmount = _luv.balanceOf(address(this));
        _luv.transfer(owner, luvAmount);
    }

    function _updateAmount(uint32 _newAmount) private {
        amount = _newAmount;
    }
}