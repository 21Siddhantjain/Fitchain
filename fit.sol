pragma solidity ^0.4.13;

contract FitChain {
    struct user {
        address addr;
        uint256 amount;
        uint256 startAt;
        uint256 endAt;
        bool isEnd;
        bool isUnsubscribed;
    }

    address public owner;
    mapping(address => uint256) public balance;
    uint256 public numUsers;
    uint256 public fee;
    uint256 public deadline;
    uint256 public monthToSecond;
    uint256 public calorieCount;

    mapping(uint256 => user) public users;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function FitChain(uint256 feePerMonth, uint256 userDeadline) {
        owner = msg.sender;
        numUsers = 0;
        fee = feePerMonth;
        deadline = userDeadline;
        monthToSecond = 2629743;
    }

    function checkDeadline() public payable onlyOwner {
        uint256 id = 0;

        while (id <= numUsers) {
            if (!users[id].isUnsubscribed) {
                users[id].isEnd = (now >= users[id].endAt + deadline);

                if (users[id].isEnd) {
                    if (!owner.send(users[id].amount)) {
                        revert();
                    }
                    users[id].isUnsubscribed = true;
                }
            }

            id++;
        }
    }

    function transfer(
        address to,
        uint256 value,
        uint256 C_count
    ) public payable onlyOwner {
        require(C_count > 500);
        balance[msg.sender] = balance[msg.sender] - value;
        balance[to] = balance[to] + value;
    }

    function pay(uint256 month) payable {
        require(msg.value == month * fee);

        uint256 id = 0;

        while (id <= numUsers) {
            if (users[id].addr == msg.sender && !users[id].isUnsubscribed) {
                users[id].amount += msg.value;
                users[id].endAt += (month * monthToSecond);
                users[id].isEnd = false;

                return;
            }

            id++;
        }

        user u = users[numUsers++];
        u.addr = msg.sender;
        u.amount = msg.value;
        u.startAt = now;
        u.endAt = u.startAt + (month * monthToSecond);
        u.isEnd = false;
        u.isUnsubscribed = false;
    }

    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
}
