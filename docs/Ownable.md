# Ownable

## Публичные методы

|Function|Parameters|Return|Description|
|---|---|---|---|
|transferOwnership|address newOwner|-//-|Передаёт права на владение контрактом другому пользователю. Может вызываться текущим владельцем|
|owner|-//-|address|Возвращает адрес владельца контракта|
|addAdmin|address account|-//-|Добавляет нового админа. Может вызываться владельцем или админами|
|removeAdmin|address account|-//-|Удаляет существующего админа. Может вызываться владельцем или админами. Проверяет, что админ существует|
|isAdmin|address account|bool|Возвращает, является ли пользователь админом|

## События

|Event|Parameters|Description|
|---|---|---|
|OwnershipTransferred|address indexed previousOwner - предыдущий владелец контракта, address indexed newOwner - новый владелец контракта|Событие вызывается, когда меняется владелец контракта|
|WhitelistAdminAdded|address indexed account - новый админ|Событие вызывается, когда добавляется новый админ|
|WhitelistAdminRemoved|address indexed account - удалённый админ|Событие вызывается, когда удаляется админ|
