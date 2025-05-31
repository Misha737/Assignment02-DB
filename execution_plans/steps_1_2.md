# Query optimization changing. Steps 1 and 2

## Step 1
В оригінальному запиті були вкладені запити, які виконувалися для кожнго рядка, що є дуже повільно. Для кращої читабильності та ефективності ці підзапити можна винести в CTE та приєднати за допомогою **JOIN**.

Для ```AvgOpponentEloInSameOpening``` я використав віконну функцію **AVG ... OVER ...**

На цьому етапі я позбувся від вкладених селектів.

Відповідь на оригінальний запит я так і недочекався, коли він вже тривав 30хв.
Без індексів, запит виконується за 40 секунд.
[](screenshots/origin_time.png)

## Step 2

Для кращого пошуку рядків я створив 2 індекси для колонок:
1. ```WhiteElo```, ```result```, ```White```
В загальному ефктивність 6 секунд. Використовується для CTE під запиту WhiteWins.

```
WhiteWins as (
		select
			count(*) as WhiteWins,
			White
		from games
		where
			WhiteElo > 2400
	        AND Result = '1-0'
	    group by White
)
```
В базі спочатку йде пошук по WhiteElo та Result, які відсортовані вже по композитному індексу. Після цього етаму, MySQL групує рядки по колонці White, який вже теж відсортований.

```
-> Aggregate using temporary table  (actual time=174..174 rows=4388 loops=1)
    -> Filter: ((games.Result = '1-0') and (games.WhiteElo > 2400))  (cost=57056 rows=22822) (actual time=0.137..138 rows=53783 loops=1)
        -> Covering index range scan on games using elo_result_white_index over (2400 < WhiteElo)  (cost=57056 rows=228219) (actual time=0.0351..122 rows=122568 loops=1)
```
MySQL вибрав covering index для пошуку. Для фільтрації очікувалось що на виході буде 22822 рядків, але вийшло 55783 рядків. Що є краще ніж це було б навпаки. Після агрегації, вийшло 4388 рядків, що зайняло 174 мс. Оціночна витрата ресурсів = 57056

[](screenshots/index_1_time.png)

2. ```White```, ```ECO```, ```Black```

+ 20.4 секунди ефективності. Індекс використовується для ```UniqueOpponentsWithSameECO``` та для ```popular_openings```

```
UniqueOpponentsWithSameECO as (
		select
			count(DISTINCT Black) as UniqueOpponentsWithSameECO,
			White,
			Eco
        from games
        group by White, ECO
)
```

```
-> Group aggregate: count(distinct games.Black)  (cost=91288 rows=456439) (actual time=0.478..1728 rows=479896 loops=1)
    -> Covering index skip scan for deduplication on games using white_eco_black_index  (cost=45644 rows=456440) (actual time=0.258..1435 rows=689257 loops=1)
```

Covering index. Очікувалось 456440 рядків, на виході 689257 рядків для пошуку. Після агрегації очікувалось 456439 рядків, на виході 479896. Очікуваня кількості резурсів - 91288. Реальний час - 1728.

```
SELECT ECO
    FROM games
    GROUP BY ECO
    HAVING COUNT(*) > 1000
```

```
-> Filter: (`count(0)` > 1000)  (actual time=672..672 rows=154 loops=1)
    -> Table scan on <temporary>  (actual time=672..672 rows=497 loops=1)
        -> Aggregate using temporary table  (actual time=672..672 rows=497 loops=1)
            -> Covering index scan on games using white_eco_black_index  (cost=250892 rows=456439) (actual time=0.04..359 rows=709496 loops=1)
```

Covering index. Фільтрація спрацювала за 672 мс. Вихід - 154 рядків. Очікувана кількість ресурсів та рядків для сканування - 250892 та 456439 відповідно. Реальна кількість рядків - 709496.

[](screenshots/index_2_time.png)

Із всіма змінами, запит відбуваєтьтся за **14 секунд**. Тобто CTE із більше ніж 30 хвилин запиту, оптимізував до 40 секунд, а додавання індексів покращило запит ще на 26 секунд.
