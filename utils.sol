// SPDX-License-Identifier: GPL-3.0
// donnie4w@gmail.com   donnie

pragma solidity >=0.8.17 <0.9.0;

contract utils {
    struct Lock {
        bool lock;
        address addr;
    }

    modifier onlyOwner(address addr) {
        require(msg.sender == addr, "must be owner");
        _;
    }

    function toBytes(address a) internal pure returns (bytes memory b) {
        assembly {
            let m := mload(0x40)
            a := and(a, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            mstore(
                add(m, 20),
                xor(0x140000000000000000000000000000000000000000, a)
            )
            mstore(0x40, add(m, 52))
            b := m
        }
    }

    function bytesConcat(bytes memory b1, bytes memory b2)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory ret = new bytes(b1.length + b2.length);
        for (uint256 i = 0; i < b1.length; ++i) {
            ret[i] = b1[i];
        }
        for (uint256 i = b1.length; i < b2.length; ++i) {
            ret[i] = b2[i];
        }
        return ret;
    }

    function compareAddress(address f, address t) internal pure returns (bool) {
        return bytesToUint(toBytes(f)) > bytesToUint(toBytes(t));
    }

    function keccak(bytes memory s) internal pure returns (bytes32) {
        return keccak256(s);
    }

    function sha(bytes memory s) internal pure returns (bytes32) {
        return sha256(s);
    }

    function shaAddress(address from, address to)
        internal
        pure
        virtual
        returns (bytes32)
    {
        return
            compareAddress(from, to)
                ? sha(toBytes(from), toBytes(to))
                : sha(toBytes(to), toBytes(from));
    }

    function sha(bytes memory s1, bytes memory s2)
        internal
        pure
        virtual
        returns (bytes32)
    {
        return sha256(abi.encodePacked(s1, s2));
    }

    function bytesToUint(bytes memory b) internal pure returns (uint256) {
        uint256 number;
        for (uint256 i = 0; i < b.length; i++) {
            number = number + uint8(b[i]) * (2**(8 * (b.length - (i + 1))));
        }
        return number;
    }

    function newAddress() public view returns (address) {
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff),
                                address(this),
                                block.timestamp
                            )
                        )
                    )
                )
            );
    }
}
