// SPDX-License-Identifier: GPL-3.0
// donnie4w@gmail.com   donnie

pragma solidity >=0.8.17 <0.9.0;

import "./utils.sol";

contract Group is utils {
    uint64 index;
    struct group {
        uint256 index;
        string info;
        address admin;
    }

    mapping(address => group) groupMap; //group  address => group

    mapping(address => address[]) user_groupArray; // msg sender => group[]

    //新建群组
    function newGroup(string memory ginfo) public virtual returns (address) {
        address addr = newAddress();
        groupMap[addr] = group(++index, ginfo, msg.sender);
        user_groupArray[msg.sender].push(addr);
        return addr;
    }

    //群信息
    function groupInfo(address groupAddress)
        public
        view
        virtual
        returns (group memory)
    {
        return groupMap[groupAddress];
    }

    //加入群组
    function joinGroup(address applicant, address groupAddress) public virtual {
        if (
            groupMap[groupAddress].admin == msg.sender &&
            !inGroup(applicant, groupAddress)
        ) {
            user_groupArray[applicant].push(groupAddress);
        }
    }

    //管理员移除群成员
    function removeMemberWithAdmin(address to, address groupAddress)
        public
        virtual
    {
        if (
            groupMap[groupAddress].admin == msg.sender &&
            inGroup(to, groupAddress)
        ) {
            for (uint256 i = 0; i < user_groupArray[to].length; i++) {
                if (user_groupArray[to][i] == groupAddress) {
                    user_groupArray[to][i] = user_groupArray[to][
                        user_groupArray[to].length - 1
                    ];
                    user_groupArray[to].pop();
                }
            }
        }
    }

    //退出群组
    function removeMember(address groupAddress) public virtual {
        if (inGroup(msg.sender, groupAddress)) {
            for (uint256 i = 0; i < user_groupArray[msg.sender].length; i++) {
                if (user_groupArray[msg.sender][i] == groupAddress) {
                    user_groupArray[msg.sender][i] = user_groupArray[
                        msg.sender
                    ][user_groupArray[msg.sender].length - 1];
                    user_groupArray[msg.sender].pop();
                }
            }
        }
    }

    //我的所有群地址
    function myGroups() public view returns (address[] memory) {
        return user_groupArray[msg.sender];
    }

    //是否在群中
    function inGroup(address to, address groupAddress)
        private
        view
        returns (bool)
    {
        for (uint256 i = 0; i < user_groupArray[to].length; i++) {
            if (user_groupArray[to][i] == groupAddress) {
                return true;
            }
        }
        return false;
    }
}
