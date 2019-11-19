pragma solidity ^0.5.11;

import "./SDC.sol";
import "./LUV.sol";
import "./Swap.sol";

contract Escrow {
    uint32 public id;
    uint256 public price;
    uint32 public amount;

    address public owner;

    event Payment(address indexed _sender, uint32 _id, uint256 _unitPrice,
                  uint32 _soldAmount, uint256 _priceSDC, uint256 _priceLUV);

    SDC private _sdc;
    LUV private _luv;
    Swap private _swap;

    uint256 private paymentGas;

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

    constructor(address _owner, uint32 _id, uint256 _price, uint32 _amount, uint256 _paymentGas,
                address _sdcAddress, address _luvAddress, address _swapAddress)
                public priceNotZero(_price) {
        _sdc = SDC(_sdcAddress);
        _luv = LUV(_luvAddress);
        _swap = Swap(_swapAddress);

        id = _id;
        price = _price;
        amount = _amount;

        owner = _owner;
        paymentGas = _paymentGas;
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

    function payment(uint32 _sellAmount,
                     address _from, uint256 _valueSDC, bytes calldata _sig)
    external enoughAmount(_sellAmount) {
        require(address(this).balance >= paymentGas * tx.gasprice,
                "Insufficient ether to return gas");

        _sdc.approveSig(_from, address(this), _valueSDC, _sig);

        uint256 neededSDC = _swap.countSDCFromLUV(_sellAmount * price);
        require(_valueSDC >= neededSDC, "Not enough SDC approved");

        uint256 balance = _sdc.balanceOf(_from);
        require(balance >= neededSDC, "Insufficient funds for payment");

        _sdc.transferFrom(_from, address(this), neededSDC);
        _sdc.approve(address(_swap), neededSDC);
        uint256 luvAmount =_swap.swap(address(this));

        _updateAmount(amount - _sellAmount);

        emit Payment(_from, id, price, _sellAmount, neededSDC, luvAmount);

        address(msg.sender).transfer(paymentGas * tx.gasprice);
    }

    function withdraw() external onlyOwner {
        uint256 luvAmount = _luv.balanceOf(address(this));
        _luv.transfer(owner, luvAmount);
    }

    function () payable external {}

    function withdrawEth() payable external onlyOwner {
        address payable addr = address(uint160(owner));
        addr.transfer(address(this).balance);
    }

    function _updateAmount(uint32 _newAmount) private {
        amount = _newAmount;
    }
}