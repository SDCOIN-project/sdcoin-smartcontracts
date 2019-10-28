pragma solidity >=0.4.21 <0.6.0;

import "./token/ERC20.sol";
import "./token/ERC20Detailed.sol";
import "./token/ERC20Mintable.sol";
import "./token/ERC20Burnable.sol";
import "./ownership/Ownable.sol";

contract LC is ERC20, ERC20Detailed, ERC20Mintable, ERC20Burnable, Ownable {
    string private NAME = "LC";
    string private SYMBOL = "LC";
    uint8 private DECIMALS = 18;

    constructor() public ERC20Detailed(NAME, SYMBOL, DECIMALS) {}
}