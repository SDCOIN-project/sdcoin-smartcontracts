# Pause

## PauserRole - Публичные методы

|Function|Parameters|Return|Description|
|---|---|---|---|
|isPauser|address account|bool|Возвращает, может ли пользователь ставить контракт на паузу|
|addPauser|address account|-//-|Добавляет нового паузера. Может вызываться только текущим паузером|
|renouncePauser|-//-|-//-|Удаляет паузера, который вызвал этот метод|

## Pausable - Публичные методы

|Function|Parameters|Return|Description|
|---|---|---|---|
|paused|-//-|bool|Возвращает, стоит ли контракт на паузе|
|pause|-//-|-//-|Ставит контракт на паузу|
|unpause|-//-|-//-|Снимает контракт с паузы|
