%% Author: wave
%% Created: 2012-10-24
%% Description: TODO: Add description to ssqiu_server_SUITE
-module(ssqiu_server_SUITE).

-compile(export_all).
-define(ACTUAL_DATA,[2,7,8,17,21,28]).

all() ->[
%% 		test_anlyse_tongji
%% 		test_he012
%% 		test_anlyse_he_jishu
%% 		test_anlyse_xiehao
%% 		test_shake
%% 		test_he_rang_10
%% 		test_part
%% 		test_anlyse_yu
		test_omg
		].

suite() ->
	[].

init_per_suite(Config) ->
	Config.

end_per_suite(_Config) ->
	ok.

test_omg(_) ->
	ssqiu_server:start_link(),
	L = [
		 {head,[1,2,3,4,5]},
%% 		 {med,[]},
		 {tail,[2]},
		 {repeat_tongji,[0]},
		 {link,[2,3]},
		 {range_sum,{74,74}},
		 {jishu,[2]},
%% 		 {xiehao,[0,1,2,3,4]},
%% 		 {he_012,[2]},
		 {include,[33]},
		 {exclude,[30,29,28,27,26,25]}
%% 		 {include,[4,5,6, 22,23,24, 3,4, 9,10, 15,16]}
%% 		 {yu,[7,21]}
		],
	
	lists:foreach(fun({Type,Value}) ->
						  ssqiu_server:temp(Type, Value) end, L),
	error_logger:info_msg("~p -- omg:~p~n", [?MODULE,ssqiu_server:get_omg()]),
	ok.

test_anlyse_repeat(_) ->
	ssqiu_server:start_link(),
	R = lists:foldl(fun(Mod,AccIn) ->
						V = ssq:auto_filter(repeat, Mod),
						[V|AccIn]
				end, [], lists:seq(7, 70)),
	error_logger:info_msg("~p -- repeat result:~p~n", [?MODULE,ssq:anlyse2(R)]),	
	ok.

test_anlyse_he_jishu(_) ->
	ssqiu_server:start_link(),
	R = lists:foldl(fun(Mod,AccIn) ->
						V = ssq:auto_filter(he_jishu, Mod),
						[V|AccIn]
				end, [], lists:seq(7, 70)),
	error_logger:info_msg("~p -- he_jishu result:~p~n", [?MODULE,ssq:anlyse2(R)]),
	ok.

test_anlyse_xiehao(_) ->
	ssqiu_server:start_link(),	
	R = lists:foldl(fun(Mod,AccIn) ->
						V = ssq:auto_filter(xiehao, Mod),
						[V|AccIn]
				end, [], lists:seq(7, 70)),
	error_logger:info_msg("~p -- xiehao result:~p~n", [?MODULE,ssq:anlyse2(R)]),
	ok.

test_anlyse_tongji(_) ->
	ssqiu_server:start_link(),
	{RR1,RR2,RR3,RR4,RR5,RR6,RR7} = lists:foldl(fun(Mod,{L1,L2,L3,L4,L5,L6,L7}) ->
						[R1,R2,R3,R4,R5,R6,R7] = ssq:auto_filter(tongji,Mod),
						{[R1|L1],[R2|L2],[R3|L3],[R4|L4],[R5|L5],[R6|L6],[R7|L7]}
				end, {[],[],[],[],[],[],[]},lists:seq(7, 70)),	
	
	error_logger:info_msg("~p -- repeat_TJ result:~p~n", [?MODULE,ssq:anlyse2(RR1)]),
	error_logger:info_msg("~p -- link_TJ result:~p~n", [?MODULE,ssq:anlyse2(RR2)]),
	error_logger:info_msg("~p -- rang_sum_TJ result:~p~n", [?MODULE,ssq:anlyse2(RR3)]),
	error_logger:info_msg("~p -- jishu_TJ result:~p~n", [?MODULE,ssq:anlyse2(RR4)]),
	error_logger:info_msg("~p -- head_TJ result:~p~n", [?MODULE,ssq:anlyse2(RR5)]),
	error_logger:info_msg("~p -- med_TJ result:~p~n", [?MODULE,ssq:anlyse2(RR6)]),
	error_logger:info_msg("~p -- tail_TJ result:~p~n", [?MODULE,ssq:anlyse2(RR7)]),
	ok.

%% no meaning
test_anlyse_yu(_) ->
	ssqiu_server:start_link(),

	RR=lists:foldl(fun(X,Acc0) ->
		R = lists:foldl(fun(Mod,AccIn) ->
						V = ssqiu_server:auto_filter(yu, {X,Mod}),
						[V|AccIn]
				end, [], lists:seq(77, 88)),	
		error_logger:info_msg("~p -- anlyse_yu_~p:~p~n", [?MODULE,X,R]),
		error_logger:info_msg("~p -- anlyse_yu_~p:~p~n", [?MODULE,X,ssq:anlyse2(R)])
	end, [], lists:seq(3, 16)),
	ok.

test_anlyse_he_spread(_) ->
	ssqiu_server:start_link(),
	RR=lists:foldl(fun(X,Acc0) ->
						L =[ 
						ssq:auto_filter(he_spread,{X,10}),
						ssq:auto_filter(he_spread,{X,20}),
						ssq:auto_filter(he_spread,{X,30}),
						ssq:auto_filter(he_spread,{X,40}),
						ssq:auto_filter(he_spread,{X,50}),
						ssq:auto_filter(he_spread,{X,60})],
						[{X,ssq:anlyse(L)}|Acc0]
						end, [],[{0,3},{3,6},{6,9},{9,12},{12,15},
								 {15,18},{18,21},{21,24},{24,27},
								 {27,30},{30,33},{33,36},{36,39},
								 {39,42},
								 {42,45},
								 {45,48},
								 {40,48},
								 {7,7}]),
	
	error_logger:info_msg("~p -- anlyse_he_spread:~p~n", [?MODULE,RR]),
	ok.	

test_he012(_) ->
	ssqiu_server:start_link(),	
	R = lists:foldl(fun(Mod,AccIn) ->
						V = ssqiu_server:auto_filter(he_012, Mod),
						[V|AccIn]
				end, [], lists:seq(7, 70)),
	
	error_logger:info_msg("~p -- he_012 result:~p~n", [?MODULE,R]),
	Fun = fun(L,Index) ->
				  lists:foldl(fun(X,Accin) ->
									  [lists:nth(Index, X)|Accin]
							  end, [], L)
		  end,
	error_logger:info_msg("~p -- he_012_0 result:~p~n", [?MODULE,ssq:anlyse2(Fun(R,1))]),
	error_logger:info_msg("~p -- he_012_1 result:~p~n", [?MODULE,ssq:anlyse2(Fun(R,2))]),
	error_logger:info_msg("~p -- he_012_2 result:~p~n", [?MODULE,ssq:anlyse2(Fun(R,3))]),
	ok.

test_shake(_) ->
	ssqiu_server:start_link(),	
	R = lists:foldl(fun(Mod,AccIn) ->
						V = ssqiu_server:auto_filter(shake, Mod),
						[V|AccIn]
				end, [], lists:seq(7, 70)),
	
	error_logger:info_msg("~p -- shake result:~p~n", [?MODULE,R]),
	Fun = fun(L,Index) ->
				  lists:foldl(fun(X,Accin) ->
									  [lists:nth(Index, X)|Accin]
							  end, [], L)
		  end,
	error_logger:info_msg("~p -- shake_daxiao result:~p~n", [?MODULE,ssq:anlyse2(Fun(R,1))]),
	error_logger:info_msg("~p -- shake_jio result:~p~n", [?MODULE,ssq:anlyse2(Fun(R,2))]),
	ok.


test_part(_) ->
	ssqiu_server:start_link(),	
	Fun = fun(Part) ->
				  R = lists:foldl(fun(Mod,AccIn) ->
						V = ssqiu_server:auto_filter(part, {Part,Mod}),
						[V|AccIn]
				end, [], lists:seq(7, 70)),
			error_logger:info_msg("~p -- part_~p result:~p~n", [?MODULE,Part,R])
		  end,
	lists:foreach(Fun, [5,6,8,11,12]),
	ok.

test_he_rang_10(_) ->
	ssqiu_server:start_link(),	
	Fun = fun(Point) ->
				  R = lists:foldl(fun(Mod,AccIn) ->
						V = ssqiu_server:auto_filter(he_range, {Point,Mod}),
						[V|AccIn]
				end, [], lists:seq(7, 70)),
			error_logger:info_msg("~p -- he_range_Point_~p result:~p~n", [?MODULE,Point,R])
		  end,
	lists:foreach(Fun, [60,70,80,90,100,110,120,130,140,150,160]),
	ok.
