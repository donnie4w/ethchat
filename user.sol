// SPDX-License-Identifier: GPL-3.0
// donnie4w@gmail.com   donnie

pragma solidity >=0.8.17 <0.9.0;
import "./utils.sol";

contract User is utils {
    uint256 userId;

    struct user {
        uint256 index;
        address addr; //用户账户
        uint256 timeunix; //注册时间
        string desc; //用户信息 json{“nick“:"dong"}
        string privateDesc; //仅个人可见信息
    }

    //完善用户资料
    function userInfo(string memory desc, string memory privateDesc)
        public
        virtual
    {
        // user memory u = user(++userId, msg.sender, block.timestamp, desc);
        user storage u = userMap[msg.sender];
        if (u.index > 0) {
            if (bytes(desc).length != 0) {
                u.desc = desc;
            }
            if (bytes(privateDesc).length != 0) {
                u.privateDesc = privateDesc;
            }
        } else {
            u.index = ++userId;
            u.addr = msg.sender;
            u.timeunix = block.timestamp;
            u.desc = desc;
            u.privateDesc = privateDesc;
        }
    }

    mapping(address => user) internal userMap;

    mapping(bytes32 => uint8) internal friendMap;

    event friend(address from, address to);

    modifier onlyFriend(address to) {
        require(
            3 == friendMap[shaAddress(to, msg.sender)],
            "Only friends can chat"
        );
        _;
    }

    //加好友，同意加好友，同一个function
    function addFriend(address friendAddress) public virtual {
        friendMap[shaAddress(msg.sender, friendAddress)] |= calculate(
            friendAddress
        );
        emit friend(msg.sender, friendAddress);
    }

    function isFriend(address to) public view virtual returns (bool) {
        return 3 == friendMap[shaAddress(to, msg.sender)];
    }

    function calculate(address addr) internal view returns (uint8) {
        return
            bytesToUint(toBytes(msg.sender)) > bytesToUint(toBytes(addr))
                ? 1
                : 2;
    }
}
