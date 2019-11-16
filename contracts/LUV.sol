pragma solidity >=0.4.21 <0.6.0;

import "./token/ERC20.sol";
import "./token/ERC20Detailed.sol";

import "./Ownable.sol";

contract LUV is ERC20, ERC20Detailed, Ownable {
    string private NAME = "LUV";
    string private SYMBOL = "LUV";
    uint8 private DECIMALS = 18;

    constructor() public ERC20Detailed(NAME, SYMBOL, DECIMALS) {}

    function mint(address account, uint256 amount) external onlyOwnerOrAdmin {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwnerOrAdmin {
        _burn(account, amount);
    }
}