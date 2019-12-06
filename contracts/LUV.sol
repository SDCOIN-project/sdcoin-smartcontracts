pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/access/roles/WhitelistedRole.sol";

/// @title LUV - ERC20 token. Stable coin
/// @notice Rate can be found in Swap contract
contract LUV is ERC20, ERC20Detailed, WhitelistedRole {
    string private NAME = "LUV";
    string private SYMBOL = "LUV";
    uint8 private DECIMALS = 18;

    constructor() public ERC20Detailed(NAME, SYMBOL, DECIMALS) {
        addWhitelisted(msg.sender);
    }

    /// @notice Mints amount of LUV on account.
    /// Can be used only by owner or admin of LUV contract
    function mint(address _account, uint256 _amount) external onlyWhitelisted {
        _mint(_account, _amount);
    }

    /// @notice Burns amount of LUV from account
    /// Can be used only by owner or admin of LUV contract
    function burn(address _account, uint256 _amount) external onlyWhitelisted {
        _burn(_account, _amount);
    }
}
