pragma solidity >=0.4.21 <0.6.0;

import "./token/ERC20.sol";
import "./token/ERC20Detailed.sol";
import "./token/ERC20Pausable.sol";

import "./Ownable.sol";
import "./Swap.sol";
import "./SigVerifier.sol";

contract SDC is ERC20, ERC20Detailed, ERC20Pausable, Ownable {
    string private NAME = "SDCOIN";
    string private SYMBOL = "SDC";
    uint8 private DECIMALS = 18;
    uint256 private INITIAL_SUPPLY = 3500000000;

    SigVerifier.Data private _nonces;

    constructor() public ERC20Detailed(NAME, SYMBOL, DECIMALS) {
        _mint(owner(), INITIAL_SUPPLY * (10 ** uint(DECIMALS)));
    }

    function getNonce(address _account) external view whenNotPaused returns(uint256) {
        return SigVerifier.getNonce(_nonces, _account);
    }

    function approveSig(address _from, address _spender, uint256 _value, bytes calldata _sig) external
    whenNotPaused {
        bool isValid = SigVerifier.verify(_nonces, _from, _spender, _value, _sig);
        require(isValid, "Invalid signature");

        _approve(_from, _spender, _value);
    }

    function mint(address account, uint256 amount) external
    whenNotPaused onlyOwnerOrAdmin {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external
    whenNotPaused onlyOwnerOrAdmin {
        _burn(account, amount);
    }
}