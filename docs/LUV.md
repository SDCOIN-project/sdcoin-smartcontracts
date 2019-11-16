# LUV

## Наследование

+ ERC20
+ ERC20Detailed
+ Ownable

## Публичные методы

|Function|Parameters|Return|Description|
|---|---|---|---|
|constructor|-//-|-//-|Создаёт контракт и зачисляет все токены на адрес создателя|
|mint|address account, uint256 amount|-//-|Создаёт новые токены. Может вызываться владельцем и админами|
|burn|address account, uint256 amount|-//-|Сжигает cуществующие токены. Может вызываться владельцем и админами|
