pragma solidity >=0.4.21 <0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Pausable.sol";

import "./Ownable.sol";
import "./Swap.sol";
import "./SigVerifier.sol";

/// @title SDC - ERC20 token. Utility coin
/// @notice Rate can be found and updated in Swap contract
contract SDC is ERC20Detailed, ERC20Pausable, Ownable {
    string private NAME = "SDCOIN";
    string private SYMBOL = "SDC";
    uint8 private DECIMALS = 18;
    uint256 private INITIAL_SUPPLY = 3500000000;

    /// @notice Nonces for signature verification
    SigVerifier.Data private _nonces;

    constructor() public ERC20Detailed(NAME, SYMBOL, DECIMALS) {
        _mint(owner(), INITIAL_SUPPLY * (10 ** uint(DECIMALS)));
    }

    /// @notice Returns current user nonce to create/verify signature
    function getNonce(address _account) external view whenNotPaused returns(uint256) {
        return SigVerifier.getNonce(_nonces, _account);
    }

    /**
        @notice Approves sum for spending like approve() method,
        but uses _from as owner of tokens. A signature is used to verify
        that _from wants to approve his tokens to _spender.
     */
    function approveSig(uint256 _value, address _from, address _spender, bytes calldata _sig) external
    whenNotPaused {
        bool isValid = SigVerifier.verify(_nonces, _from, _spender, _sig);
        require(isValid, "Invalid signature");

        _approve(_from, _spender, _value);
    }

    /// @notice Mints amount of SDC on account
    /// Can be used only by owner or admin of LUV contract
    function mint(address account, uint256 amount) external
    whenNotPaused onlyOwnerOrAdmin {
        _mint(account, amount);
    }

    /**
        @notice Burns amount of SDC from account and removes
        allowance for this amount
        Can be used only by owner or admin of LUV contract
     */
    function burnFrom(address account, uint256 amount) external
    whenNotPaused onlyOwnerOrAdmin {
        _burnFrom(account, amount);
    }
}
