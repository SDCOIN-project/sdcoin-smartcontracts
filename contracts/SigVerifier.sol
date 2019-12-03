pragma solidity ^0.5.11;

library SigVerifier {
    struct Data {
        /**
            @dev Nonces used to create unique signature
            Every user has personal nonce counter which increases
            every time signature verified
        */
        mapping(address => uint256) _nonces;
    }

    /// @dev Necessary constant for ecrecover
    bytes constant APPROVE_MSG_PREFIX = "\x19Ethereum Signed Message:\n32";

    /// @notice Returns current nonce for account
    function getNonce(Data storage _self, address _account) internal view returns(uint256) {
        return _self._nonces[_account];
    }

    /**
        @notice Verifies signature
        @param _self - library object which contains nonces
        @param _from - account which creates signature
        @param _to - account which somehow interacts with _from
        @param _sig - signature for verifing
        @dev Steps to create valid signature
        1. Get current nonce for _from
        2. Pack together next params:
            bytes20(_from) + bytes12(0)
            + bytes20(_to) + bytes12(0)
            + uint256(nonce)
        3. Take SHA3 hash from packed parameters
        4. Sign hash with _from's private key
     */
    function verify(Data storage _self, address _from, address _to, bytes memory _sig)
    internal returns(bool) {
        require(_sig.length == 65, "Invalid signature length");

        bytes12 offset;

        bytes32 prefixed = keccak256(abi.encodePacked(
            APPROVE_MSG_PREFIX, keccak256(abi.encodePacked(
                bytes20(_from), offset,
                bytes20(_to), offset,
                _self._nonces[_from]))));

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

        if (isEqual) _self._nonces[_from]++;

        return isEqual;
    }
}