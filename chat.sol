// SPDX-License-Identifier: GPL-3.0
// donnie4w@gmail.com   donnie

pragma solidity >=0.8.17 <0.9.0;
import "./user.sol";
import "./group.sol";

contract Chat is User, Group {
    //聊天单元
    struct chatunit {
        address from;
        string content;
        uint256 time;
        uint256 seq;
    }

    struct recvUint {
        uint256 seq;
        Lock syncSeq;
        mapping(uint256 => chatunit) chatgroup;
    }

    modifier syncSeq(recvUint storage recv) {
        require(!recv.syncSeq.lock, "lock now,please try again");
        recv.syncSeq.lock = true;
        ++recv.seq;
        recv.syncSeq.lock = false;
        _;
    }

    function writeToChatunit(recvUint storage recv, chatunit memory cuint)
        internal
        syncSeq(recv)
    {
        cuint.seq = recv.seq;
        recv.chatgroup[recv.seq] = cuint;
    }

    mapping(address => recvUint) chatgroup; //   to => map(seq=>chatuint)

    //接收消息事件
    event msgRecv(address to, address from, uint256 time, string content);

    function sendMsg(address to, string calldata content)
        public
        onlyFriend(to)
    {
        uint256 time = block.timestamp;
        writeToChatunit(chatgroup[to], chatunit(msg.sender, content, time, 0));
        emit msgRecv(to, msg.sender, time, content);
    }

    function getMsg(
        address to,
        uint256 seqId,
        uint64 pageNumber
    ) public view onlyOwner(to) returns (chatunit[] memory) {
        recvUint storage recv = chatgroup[to];
        uint256 length = pageNumber;
        if (recv.seq - seqId < pageNumber) {
            length = recv.seq - seqId;
        }
        chatunit[] memory ret = new chatunit[](length);
        if (seqId < recv.seq) {
            for (uint256 i = 0; i < length; ++i) {
                ret[i] = recv.chatgroup[i + seqId + 1];
            }
        }
        return ret;
    }
}
