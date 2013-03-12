%% Author: chao
%% Created: Oct 27, 2012
%% Description: TODO: Add description to ssq
-module(ssq).
%%1107568 
-export([load_raw_data/1,
		 init_raw_file/1,
		 jieche/2,
		 call/2,
		 get/1,
		 auto_filter/0,
		 auto_filter/2,
		 range2/2,
		 anlyse/1,
		 anlyse2/1
		 ]).
-include("ssq.hrl").

init_raw_file(Path) ->
	FileName = Path ++ "/.ssq_raw",
	file:close(FileName),
	error_logger:info_msg("~p -- init ssq raw file:~p~n ", [?MODULE,FileName]),
	{ok,Io} = file:open(FileName, [write,append]),
	select_one_from(Io).

select_one_from(Io) ->
	L1 = lists:seq(1, 33),
	L2 = lists:seq(1, 33),
	L3 = lists:seq(1, 33),
	L4 = lists:seq(1, 33),
	L5 = lists:seq(1, 33),
	L6 = lists:seq(1, 33),
	Fun = fun(X1,X2,X3,X4,X5,X6) ->
			file:write(Io,[X1,X2,X3,X4,X5,X6] ) 
		  end,	 
	[Fun(X1,X2,X3,X4,X5,X6) || X1 <- L1,
							   X2 <- L2,
							   X3 <- L3,
							   X4 <-L4,
							   X5<-L5,
							   X6<-L6,
							   X1 < X2,
							   X2 < X3,
							   X3 < X4,
							   X4 < X5,
							   X5 < X6],
	file:close(Io),
	ok.


load_raw_data(Filename) ->
	{ok,Bin} = file:read_file(Filename),
	loop_load(Bin,[]).

loop_load(<<>>,R) ->
	R;
loop_load(<<H1,H2,H3,H4,H5,H6,Rest/binary>>,R) ->
	loop_load(Rest,[[H1,H2,H3,H4,H5,H6]|R]).


jieche(M,N) ->
	che(N) / che(M) /che(N-M).

che(1) ->
	1;
che(N) ->
	N * che(N-1).

call(cr,{No,Value}) ->
	gen_server:call(ssqiu_server, {call,clear_range,{No,Value}}),
	ok;
call(ji,Value) ->
	gen_server:call(ssqiu_server, {call,jio_ji,Value}),
	ok.

auto_filter(tongji,Mod) ->
	R = ssqiu_server:auto_filter(tongji, Mod),
	error_logger:info_msg("~p -- auto_filter tongji:~p~n", [?MODULE,R]),
	R;

auto_filter(he_jishu,Mod) ->
	R={CV,{Min,Max},Mod} = ssqiu_server:auto_filter(he_jishu, Mod),
	error_logger:info_msg("~p -- auto_filter he_jishu:~p~n", [?MODULE,R]),
	R;

%%no meaning
auto_filter(he_range,{Spoint,Mod}) ->
	R = {CurrentValue,R2,Spoint,Mod} = ssqiu_server:auto_filter(he_range,{Spoint,Mod}),
	error_logger:info_msg("~p -- auto_filter he_range:~p~n", [?MODULE,R]),
	R;

%%Range include left and right
auto_filter(he_spread,{Range,Mod}) ->
	R = {CurrentValue,R2,Spoint,Mod} = ssqiu_server:auto_filter(he_spread,{Range,Mod}),
%% 	error_logger:info_msg("~p -- auto_filter he_spread:~p~n", [?MODULE,R]),
	R;

auto_filter(repeat,Mod) ->
	R = {{Min,Max},Mod} = ssqiu_server:auto_filter(repeat, Mod),
	error_logger:info_msg("~p -- auto_filter repeat:~p~n", [?MODULE,R]),
	R;

auto_filter(xiehao,Mod) ->
	R = {CV,{Min,Max},Mod} = ssqiu_server:auto_filter(xiehao, Mod),
	error_logger:info_msg("~p -- auto_filter xiehao:~p~n", [?MODULE,R]),
	R;
auto_filter(yu,{Yu,Mod}) ->
	R = {CV,{Min,Max},Yu,Mod} = ssqiu_server:auto_filter(yu,{Yu,Mod}),
	error_logger:info_msg("~p -- auto_filter yu:~p~n", [?MODULE,R]),
	R;
auto_filter(shake,Mod) ->
	R = [{CV1,Range1,Mod},{CV2,Range2,Mod}] = ssqiu_server:auto_filter(shake,Mod),
	error_logger:info_msg("~p -- auto_filter shake:~p~n", [?MODULE,R]),
	R.


get(merge) ->
	gen_server:call(ssqiu_server, {call,merge}).




anlyse(L) ->
	anlyse(L,[]).
anlyse([],[]) ->
	-1;
anlyse([],R) ->
	VL = length(R) - lists:sum(R),
	Half = length(R) /2,
	if
		VL  < Half ->
			1;
		VL > Half ->
			0;
		true ->
			-1
	end;
anlyse([{CV,{VL,VR},_,Mod}|T],R) ->
	anlyse([{CV,{VL,VR},Mod}|T],R);
anlyse([{CV,{VL,VR},Mod}|T],R) when VL == VR->
	anlyse(T,R);
anlyse([{CV,{VL,VR},Mod}|T],R) when CV < VL ->
	anlyse(T,[0|R]);
anlyse([{CV,{VL,VR},Mod}|T],R) when VR =<CV  ->
	anlyse(T,[1|R]);
anlyse([{CV,{VL,VR},Mod}|T],R) ->
	anlyse(T,R).

%%{Min,Max}
%%Value choosed,must meet Min =< Value =< Max
anlyse2(L) ->
	anlyse2(L,{[0],[999]}).
anlyse2([],{MaxL,MinR}) ->
	[{min,lists:max(MaxL)},{max,lists:min(MinR)}];
anlyse2([{CV,{VL,VR},X,_}|T],{MaxL,MinR}) ->
	anlyse2([{CV,{VL,VR},X}|T],{MaxL,MinR});
anlyse2([{CV,{VL,VR},_}|T],{MaxL,MinR}) when CV < VL->
	anlyse2(T,{[VL-CV|MaxL],MinR});
anlyse2([{CV,{VL,VR},_}|T],{MaxL,MinR}) when CV =< VR ->
	anlyse2(T,{MaxL,[VR-CV|MinR]}).

auto_filter() ->

	auto_filter(repeat,1),
	auto_filter(repeat,2),
	auto_filter(repeat,3),
	auto_filter(repeat,4),
	auto_filter(repeat,7),
	auto_filter(repeat,9),
	auto_filter(repeat,17),
	
	auto_filter(xiehao,5),
	auto_filter(xiehao,10),
	auto_filter(xiehao,16),
	auto_filter(xiehao,31),
	
	auto_filter(shake,10),
	auto_filter(shake,21),
	auto_filter(shake,31),
	auto_filter(shake,40),

	Y1 = 10,
	auto_filter(yu,{3,Y1}),
	auto_filter(yu,{4,Y1}),
	auto_filter(yu,{5,Y1}),
	auto_filter(yu,{6,Y1}),
	auto_filter(yu,{7,Y1}),
	auto_filter(yu,{8,Y1}),
	auto_filter(yu,{9,Y1}),
	auto_filter(yu,{10,Y1}),
	auto_filter(yu,{11,Y1}),
	
	Y2=20,
	auto_filter(yu,{3,Y2}),
	auto_filter(yu,{4,Y2}),
	auto_filter(yu,{5,Y2}),
	auto_filter(yu,{6,Y2}),
	auto_filter(yu,{7,Y2}),
	auto_filter(yu,{8,Y2}),
	auto_filter(yu,{9,Y2}),
	auto_filter(yu,{10,Y2}),
	auto_filter(yu,{11,Y2}),	
	ok.

range2(CASE,N) ->
	 case whereis(ssqiu_server) of
		 undefined ->
			 ssqiu_server:start_link();
		 _ ->
			 ok
	 end,
	 ssqiu_server:temp(rest, 0),
	 R = {_,Len,L}=lists:foldl(fun({Key,Value},AccIn) ->
						 ssqiu_server:temp(Key,Value) end, 0, CASE),
	 LL = if
		 Len =< N ->
			 L;
		 true ->
			 lists:foldl(fun(Index,AccIn) ->
								 Omg = lists:nth(random:uniform(Len), L),
								 [Omg|AccIn]
						 end, [], lists:seq(1, N))
	 end,
	 error_logger:info_msg("~p-- random ~p from ~p,omg:~n~p~n", [?MODULE,length(LL),Len,LL]).
			
			
	
	
	
	
	

