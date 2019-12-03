# Ownable

## Public methods

|Function|Parameters|Return|Description|
|---|---|---|---|
|transferOwnership|address newOwner|-//-|Transfers ownership rights to newOwner. Can be called only by current contract owner|
|owner|-//-|address|Returns address of current contract owner|
|addAdmin|address account|-//-|Adds new admin. Can be called only by owner or admin|
|removeAdmin|address account|-//-|Removes existing admin. Can be called only by owner or admin|
|isAdmin|address account|bool|Checks if account is admin|

## Events

|Event|Parameters|Description|
|---|---|---|
|OwnershipTransferred|address indexed previousOwner - previous owner of contract, address indexed newOwner - new contract owner|Emits when contract owner changes|
|WhitelistAdminAdded|address indexed account - new admin|Emits when new admin added|
|WhitelistAdminRemoved|address indexed account - removed admin|Emits when admin removed|
