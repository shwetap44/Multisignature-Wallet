// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract MultiSig {

    address[] public owners;
    uint public numConfirmationsRequired;

    struct Transaction {
        address to;
        uint value;
        bool executed;
    }

    mapping(uint=> mapping(address => bool)) isConfirmed;
    Transaction[] public transactions;
    event TransactionSubmitted(uint transactionId, address sender, address receiver, uint amount);
    event TransactionConfirmed(uint transactionId);
    event TransactionExecuted(uint transactionId);

    constructor(address[] memory _owners, uint _numConfirmationsRequired) {

        require(_owners.length > 1, "Owners required must be grater than 1");
        require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length, "Num of confirmations are not in sync with number of owners");

        for(uint i=0; i < _owners.length; i++){
            require(_owners[i] != address(0), "Invalid owner");
            owners.push(_owners[i]);
        }
        numConfirmationsRequired = _numConfirmationsRequired;
    }

    function submitTransaction(address _to) public payable{

        require(_to != address(0),"Invalid receiver address");
        require(msg.value > 0, "Transfer amount must be greater than 0");

        uint transactionId = transactions.length;
        transactions.push(Transaction(_to, msg.value, false));
        emit TransactionSubmitted(transactionId, msg.sender, _to, msg.value);
    }

    function confirmTransaction(uint _transactionId) public {

        require(_transactionId < transactions.length, "Invalid Transaction Id");
        require(!isConfirmed[_transactionId][msg.sender], "Transaction is already confirmed by owner");
        isConfirmed[_transactionId][msg.sender] = true;
        emit TransactionConfirmed(_transactionId);

        if(isTransactionConfirmed(_transactionId)) {
            executeTransaction(_transactionId);
        }
    }

    function isTransactionConfirmed(uint _transactionId) internal view returns(bool) {
        
        require(_transactionId < transactions.length, "Invalid Transaction Id");
        uint confirmationCount;

        for(uint i; i< owners.length; i++) {

            if(isConfirmed[_transactionId][owners[i]]) {
                confirmationCount++;
            }
        }

        return confirmationCount >= numConfirmationsRequired;
    }

    function executeTransaction(uint _transactionId) public payable {

        require(_transactionId < transactions.length, "Invalid Transaction Id");
        require(!transactions[_transactionId].executed,"Transaction is already executed");

        (bool success,) = transactions[_transactionId].to.call{value: transactions[_transactionId].value}("");
        require(success, "Transaction execution failed");
        transactions[_transactionId].executed = true;

        emit TransactionExecuted(_transactionId);
    }


}
