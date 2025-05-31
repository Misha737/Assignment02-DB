use tournament_chess_games;

create index elo_result_white_index on games (WhiteElo, Result, White);
create index white_eco_black_index on games (White, ECO, Black);

show indexes from games;