use tournament_chess_games;

create index elo_result_white_index on games (WhiteElo, Result, White);
create index white_index on games (White);

show indexes from games;