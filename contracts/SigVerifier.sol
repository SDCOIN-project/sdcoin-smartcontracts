pragma solidity ^0.5.11;

library SigVerifier {
    struct Data {
        mapping(address => uint256) _nonces;
    }

    bytes constant APPROVE_MSG_PREFIX = "\x19Ethereum Signed Message:\n32";

    function getNonce(Data storage self, address _account) internal view returns(uint256) {
        return self._nonces[_account];
    }

    function verify(Data storage self, address _from, address _spender, uint256 _value, bytes memory _sig)
    internal returns(bool) {
        require(_sig.length == 65, "Invalid signature length");

        bytes12 offset;

        bytes32 prefixed = keccak256(abi.encodePacked(
            APPROVE_MSG_PREFIX, keccak256(abi.encodePacked(
                bytes20(_from), offset,
                bytes20(_spender), offset,
                _value, self._nonces[_from]))));

        bytes memory sig = _sig;

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 0x20))
            s := mload(add(sig, 0x40))
            v := byte(0, mload(add(sig, 0x60)))
        }

        if (v == 0 || v == 1)
            v += 27;

        require(v == 27 || v == 28, "Invalid v value (last byte) in signature");

        address recAddr = ecrecover(prefixed, v, r, s);
        bool isEqual = (recAddr == _from);

        if (isEqual) self._nonces[_from]++;

        return isEqual;
    }
}