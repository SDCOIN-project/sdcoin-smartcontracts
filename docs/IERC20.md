# ERC20

## IERC20 - Публичные методы

|Function|Parameters|Return|Description|
|---|---|---|---|
|totalSupply|-//-|uint256|Возвращает количество токенов|
|balanceOf|address account|uint256|Возвращает баланс аккаунта|
|transfer|address recipient, uint256 amount|bool|Перевод средств на некоторый аккаунт|
|allowance|address owner, address spender|uint256|Возвращает сумму, которую owner разрешил потратить spender. См. approve|
|approve|address spender, uint256 value|bool|Владелец средств разрешает spender потратить сумму = value. См. allowance|
|transferFrom|address sender, address recipient, uint256 amount|bool|Перевод разрешенных средств (amount) от sender на адрес recipient|

## ERC20Detailed - Публичные методы

|Function|Parameters|Return|Description|
|---|---|---|---|
|constructor|string memory name, string memory symbol, uint8 decimals|-//-|-//-|
|name|-//-|string|Возвращает полное имя токена|
|symbol|-//-|string|Возвращает символ токена (обычно краткое имя)|
|decimals|-//-|uint8|Возвращает количество цифр после запятой для токена|
