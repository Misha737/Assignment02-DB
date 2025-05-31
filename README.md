# Assignment 2

Посилання на базу даних: [Tournament Chess Games](https://www.kaggle.com/datasets/lichess/tournament-chess-games/)

Це база турнірів із шахів на 700 000+ рядків.
|Field|Type|
|-----|----|
Event|	varchar(300)
Site|	varchar(200)
White|	varchar(50)
Black|	varchar(50)
Result|	varchar(50)
WhiteTitle|	varchar(50)
BlackTitle|	varchar(50)
WhiteFideId|	varchar(50)
BlackFideId	|varchar(50)
WhiteElo|	double
BlackElo|	double
UTCDate	|date
UTCTime	|time
ECO	|varchar(50)
Opening|	varchar(128)
Termination|	varchar(50)
TimeControl	|varchar(200)
Board	|varchar(50)
Variant	|varchar(50)
StudyName|	varchar(100)
ChapterName	|varchar(100)
BroadcastName|	varchar(100)
BroadcastURL|	varchar(200)
GameURL	|varchar(200)
movetext|	text

## Qeury
Надсилає запит на 50 рядків по кожному турніру. Тобто:
* локація проведення турніру (Site)
* дата (UTCDate)
* імена суперників (White, Black) та їхній ігровий рейтинг (WhiteElo, BlackElo)
* результат (Result)
* дебют (Opening)
* кількість перемог у білого гравця, коли його рейтинг був більше 2400 (WhiteWins)
* кількість унікальних суперників булого із однаковим дебютом (UniqueOpponentsWithSameECO)
* середній рейтинг чорного гравця серед гравців із однаковим дебютом та не більше року до поточного рядка (AvgOpponentEloInSameOpening).

Відбирає ті рядки, в яких кількість одинакових дебютів більше 1000. Та фільтрує за даним критерієм:
```
e1.WhiteTitle = 'GM'
    AND e1.BlackTitle = 'GM'
    AND e1.Variant = 'Standard'
    AND e1.TimeControl LIKE '600+%'
    AND e1.Termination != 'Time forfeit'
```

Сортує за кількістю виграшам білих гравців та AvgOpponentEloInSameOpening в порядку спадання.

## Optimazation
Щоб зменшити кількість повторюваних під запитів, було використано CTE. Також для деяких під запитів було створено індекси.

Execution plans:

[Steps 1 and 2](execution_plans/steps_1_2.md)

[Step 3](execution_plans/step_3.md)

Explanations:

[Step 1](explanations/step1_explanation.txt)

[Step 2](explanations/step2_explanation.txt)

[Step 3](explanations/step3_explanation.txt)
