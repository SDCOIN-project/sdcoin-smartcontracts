# Swap

## Наследование

+ Ownable

## Публичные методы

|Function|Parameters|Return|Description|
|---|---|---|---|
|constructor|uint256 _exchangeRate, address _sdcAddress, address _luvAddress|-//-|Создаёт контракт и устанавливает курс валют, а также адреса контрактов токенов SDC и LUV|
|swap|address receiver|uint256|Производит конвертацию средств из SDC в LUV, а также перевод на адрес recipient|
|countSDCFromLUV|uint256 luvAmount|uint256|Подсчитывает, сколько SDC нужно, чтобы при конвертации получить необходимую сумму LUV (luvAmount)|
|updateRate|uint256 _exchangeRate|-//-|Устанавливает текущий курс валют (сколько KRW в SDC). Может вызываться только владельцем или админом|

## Геттеры

|Getter|Type|Description|
|---|---|---|
|sdc|address|Возвращает адрес SDC контракта|
|luv|address|Возвращает адрес LUV контракта|
