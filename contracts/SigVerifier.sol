pragma solidity ^0.5.0;

library SigVerifier {
    struct Data {
        /** @dev Nonces used to create unique signature
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

    /** @notice Verifies signature
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

        bytes32 prefixed = keccak256(abi.encodePacked(
            APPROVE_MSG_PREFIX, keccak256(abi.encodePacked(
                bytes32(bytes20(_from)),
                bytes32(bytes20(_to)),
                _self._nonces[_from]))));

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := calldataload(add(_sig, 0x24))
            s := calldataload(add(_sig, 0x44))
            v := byte(0, calldataload(add(_sig, 0x64)))
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