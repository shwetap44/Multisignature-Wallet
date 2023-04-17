# Multisignature-Wallet

1. Multisignature wallet has more than a person for authorising a transaction.
2. While deploying the contract, owners' addresses should be provided  along with minimum no of confirmations required to execute a transaction.
3. Once a transaction is submitted it will get added to an array (similar to mempool) and it will get executed if it is a valid transaction
4. It is still not confirmed. For confirmation number of confirmations will be counted and if they are grater than or equal to minimum confirmations required. Transaction will get confirmed.
