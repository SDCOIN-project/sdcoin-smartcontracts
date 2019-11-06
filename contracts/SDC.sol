pragma solidity >=0.4.21 <0.6.0;

import "./token/ERC20.sol";
import "./token/ERC20Detailed.sol";
import "./token/ERC20Mintable.sol";
import "./token/ERC20Burnable.sol";
import "./ownership/Ownable.sol";
import "./access/roles/WhitelistAdminRole.sol";

import "./Swap.sol";

contract SDCoin is ERC20, ERC20Detailed, WhitelistAdminRole {
    string private NAME = "SDCOIN";
    string private SYMBOL = "SDC";
    uint8 private DECIMALS = 18;
    uint256 private INITIAL_SUPPLY = 3500000000;

    address public SwapAddress;

    address private _owner;
    mapping(address => uint256) private _nonces;

    bytes private APPROVE_MSG_PREFIX = "\x19Ethereum Signed Message:\n32";

    constructor(uint256 _exchangeRate, address[] memory _admins) public ERC20Detailed(NAME, SYMBOL, DECIMALS) {
        _owner = msg.sender;
        addWhitelistAdmin(_owner);
        _mint(_owner, INITIAL_SUPPLY * (10 ** uint(DECIMALS)));

        Swap swap = new Swap(_exchangeRate, _admins);
        SwapAddress = address(swap);
        addWhitelistAdmin(SwapAddress);


        for (uint8 i = 0; i < _admins.length; i++) {
            addWhitelistAdmin(_admins[i]);
        }
    }

    function getNonce(address _who) external view returns (uint256) {
        return _nonces[_who];
    }

    function approveSig(address _from, address _spender, uint256 _value, bytes calldata _sig) external {
        require(_sig.length == 65, "Invalid signature length");

        bytes12 offset;

        bytes32 prefixed = keccak256(abi.encodePacked(
            APPROVE_MSG_PREFIX,
            keccak256(abi.encodePacked(
                bytes20(_from), offset,
                bytes20(_spender), offset,
                _value, _nonces[_from]))));

        bytes memory sig = _sig;

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 0x20))
            s := mload(add(sig, 0x40))
            v := byte(0, mload(add(sig, 0x60)))
        }

        address recAddr = ecrecover(prefixed, v, r, s);
        require(recAddr == _from, "Invalid signature");

        _approve(_from, _spender, _value);
        _nonces[_from] = _nonces[_from] + 1;
    }

    function mint(address account, uint256 amount) external onlyWhitelistAdmin {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyWhitelistAdmin {
        _burn(account, amount);
    }
}