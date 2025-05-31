use tournament_chess_games;

explain analyze with
	WhiteWins as (
		select
			count(*) as WhiteWins,
			White
		from games
		where
			WhiteElo > 2400
	        AND Result = '1-0'
	    group by White
	),
	UniqueOpponentsWithSameECO as (
		select
			count(DISTINCT Black) as UniqueOpponentsWithSameECO,
			White,
			Eco
        from games
        group by White, ECO
	)
select
    e1.Site,
    e1.UTCDate,
    e1.White,
    e1.Black,
    e1.WhiteElo,
    e1.BlackElo,
    e1.Result,
    e1.Opening,
    e2.WhiteWins,
    e3.UniqueOpponentsWithSameECO,
    avg(e1.BlackElo) over (
        partition by e1.Opening
        order by e1.UTCDate
        range between interval 1 year preceding and current row
    ) as AvgOpponentEloInSameOpening
from
    games e1
join (
    select ECO
    from games
    group by ECO
    having count(*) > 1000
) popular_openings ON e1.ECO = popular_openings.ECO
join WhiteWins e2
	on e1.White = e2.White
join UniqueOpponentsWithSameECO e3
	on e1.White = e3.White and
		e1.ECO = e3.ECO
where
    e1.WhiteTitle = 'GM'
    and e1.BlackTitle = 'GM'
    and e1.Variant = 'Standard'
    and e1.TimeControl LIKE '600+%'
    and e1.Termination != 'Time forfeit'
order by
    e2.WhiteWins desc,
    AvgOpponentEloInSameOpening desc
limit 50;