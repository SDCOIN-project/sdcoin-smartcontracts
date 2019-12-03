pragma solidity >=0.4.21 <0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

import "./Ownable.sol";

/// @title LUV - ERC20 token. Stable coin
/// @notice Rate can be found in Swap contract
contract LUV is ERC20, ERC20Detailed, Ownable {
    string private NAME = "LUV";
    string private SYMBOL = "LUV";
    uint8 private DECIMALS = 18;

    constructor() public ERC20Detailed(NAME, SYMBOL, DECIMALS) {}

    /// @notice Mints amount of LUV on account.
    /// Can be used only by owner or admin of LUV contract
    function mint(address account, uint256 amount) external onlyOwnerOrAdmin {
        _mint(account, amount);
    }

    /// @notice Burns amount of LUV from account
    /// Can be used only by owner or admin of LUV contract
    function burn(address account, uint256 amount) external onlyOwnerOrAdmin {
        _burn(account, amount);
    }
}
