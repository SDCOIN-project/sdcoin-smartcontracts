// File: contracts/Sdcoin.sol

pragma solidity >=0.4.21 <0.6.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Mintable.sol";
import "./ERC20Burnable.sol";
import "./ERC20Pausable.sol";
import "./Ownable.sol";

contract Sdcoin is ERC20, ERC20Detailed, ERC20Mintable, ERC20Burnable, ERC20Pausable, Ownable {
    string private NAME = "SDCOIN";
    string private SYMBOL = "SDC";
    uint8 private DECIMALS = 18;
    uint256 private INITAIL_SUPPLY = 3500000000;

    constructor() public ERC20Detailed(NAME, SYMBOL, DECIMALS) {
        mint(owner(), INITAIL_SUPPLY * (10 ** uint(DECIMALS)));
    }
}