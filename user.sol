// SPDX-License-Identifier: GPL-3.0
// donnie4w@gmail.com   donnie

pragma solidity >=0.8.17 <0.9.0;
import "./utils.sol";
import "./group.sol";

contract User is utils, Group {
    uint256 internal userId;

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

    mapping(address => user) private userMap;

    mapping(bytes32 => uint8) private friendMap;

    event friend(address from, address to);

    modifier onlyFriendorInGroup(address to) {
        require(
            3 == friendMap[shaAddress(to, msg.sender)] ||
                inGroup(msg.sender, to),
            "Only friends or group member can send message"
        );
        _;
    }

    modifier onlyOwnerOrInGroup(address addr) {
        require(msg.sender == addr || inGroup(msg.sender, addr), "must be owner or group member");
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
