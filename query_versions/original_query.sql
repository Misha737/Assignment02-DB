USE tournament_chess_games;

DESCRIBE games;

SELECT
    e1.Site,
    e1.UTCDate,
    e1.White,
    e1.Black,
    e1.WhiteElo,
    e1.BlackElo,
    e1.Result,
    e1.Opening,
    (
        SELECT COUNT(*)
        FROM games e2
        WHERE e2.White = e1.White
          AND e2.WhiteElo > 2400
          AND e2.Result = '1-0'
    ) AS WhiteWins,
    (
        SELECT AVG(e3.BlackElo)
        FROM games e3
        WHERE e3.Opening = e1.Opening
          AND e3.UTCDate BETWEEN DATE_SUB(e1.UTCDate, INTERVAL 1 YEAR) AND e1.UTCDate
    ) AS AvgOpponentEloInSameOpening,
    (
        SELECT COUNT(DISTINCT e4.BlackFideId)
        FROM games e4
        WHERE e4.White = e1.White
          AND e4.ECO = e1.ECO
    ) AS UniqueOpponentsWithSameECO
FROM
    games e1
JOIN (
    SELECT ECO
    FROM games
    GROUP BY ECO
    HAVING COUNT(*) > 1000
) popular_openings ON e1.ECO = popular_openings.ECO
WHERE
    e1.WhiteTitle = 'GM'
    AND e1.BlackTitle = 'GM'
    AND e1.Variant = 'Standard'
    AND e1.TimeControl LIKE '600+%'
    AND e1.Termination != 'Time forfeit'
ORDER BY
    WhiteWins DESC,
    AvgOpponentEloInSameOpening DESC
LIMIT 50;