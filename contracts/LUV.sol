pragma solidity >=0.4.21 <0.6.0;

import "./token/ERC20.sol";
import "./token/ERC20Detailed.sol";
import "./token/ERC20Mintable.sol";
import "./token/ERC20Burnable.sol";
import "./ownership/Ownable.sol";
import "./access/roles/WhitelistAdminRole.sol";

import "./Swap.sol";

contract LUV is ERC20, ERC20Detailed, WhitelistAdminRole {
    string private NAME = "LUV";
    string private SYMBOL = "LUV";
    uint8 private DECIMALS = 18;

    constructor(address[] memory _admins) public ERC20Detailed(NAME, SYMBOL, DECIMALS) {
        addWhitelistAdmin(msg.sender);
        for (uint8 i = 0; i < _admins.length; i++) {
            addWhitelistAdmin(_admins[i]);
        }
    }

    function mint(address account, uint256 amount) external onlyWhitelistAdmin {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyWhitelistAdmin {
        _burn(account, amount);
    }
}