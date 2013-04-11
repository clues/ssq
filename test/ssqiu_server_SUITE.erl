%% Author: wave
%% Created: 2012-10-24
%% Description: TODO: Add description to ssqiu_server_SUITE
-module(ssqiu_server_SUITE).

-compile(export_all).
-define(ACTUAL_DATA,[2,10,11,19,22,25]).

all() ->[
%% 		test_anlyse_tongji
%% 		test_he012
%% 		test_anlyse_he_jishu
%% 		test_anlyse_xiehao
%% 		test_anlyse_horse_yue
		test_anlyse_horse_ri
%% 		test_shake
%% 		test_he_rang_10
%% 		test_rem_he
%% 		test_part
%% 		test_anlyse_yu
%% 		test_anlyse_he_spread
%% 		test_link_he
%% 		test_rem_same
%% 		test_omg
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
%% 		 {head,[3]},
%% 		 {med,[1]},
		 {tail,[1,2,3,4,5]},
		 {repeat_tongji,[0]},
		 {link,[3]},
		 {range_sum,{107,107}},
		 {jishu,[5]},
		 {xiehao,[2,3]},
%% 		 {part,[{1,6},{0,1}]},
%% 		 {part,[{19,24},{2,7}]},
		 {part,[{7,8},{1,7}]},
		 {part,[{19,25},{2,7}]},
%% 		 {rem_he,{2,{1,6}}},
%% 		 {rem_he,{5,{1,8}}},
%% 		 {include,[1]},
%% 		 {exclude,[4,5,6,7,8]},
%% 		 {include,[4,5,6, 22,23,24, 3,4, 9,10, 15,16]},
%% 		 {yu,[7,21]},
		{he_012,[2]}
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
test_anlyse_horse_yue(_) ->
	ssqiu_server:start_link(),	
	R = lists:foldl(fun(Mod,AccIn) ->
						V = ssq:auto_filter(horse_yue, Mod),
						[V|AccIn]
				end, [], lists:seq(7, 70)),
	error_logger:info_msg("~p -- horse_yue result:~p~n", [?MODULE,ssq:anlyse2(R)]),
	ok.

test_anlyse_horse_ri(_) ->
	ssqiu_server:start_link(),	
	R = lists:foldl(fun(Mod,AccIn) ->
						V = ssq:auto_filter(horse_ri, Mod),
						[V|AccIn]
				end, [], lists:seq(7, 70)),
	error_logger:info_msg("~p -- horse_ri result:~p~n", [?MODULE,ssq:anlyse2(R)]),
	ok.

test_anlyse_tongji(_) ->
	ssqiu_server:start_link(),
	{RR1,RR2,RR3,RR4,RR5,RR6,RR7} = lists:foldl(fun(Mod,{L1,L2,L3,L4,L5,L6,L7}) ->
						[R1,R2,R3,R4,R5,R6,R7] = ssq:auto_filter(tongji,Mod),
						{[R1|L1],[R2|L2],[R3|L3],[R4|L4],[R5|L5],[R6|L6],[R7|L7]}
				end, {[],[],[],[],[],[],[]},lists:seq(16, 70)),	
	
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
				end, [], lists:seq(7, 77)),	
		error_logger:info_msg("~p -- anlyse_yu_~p:~p~n", [?MODULE,X,R]),
		error_logger:info_msg("~p -- anlyse_yu_~p:~p~n", [?MODULE,X,ssq:anlyse2(R)])
	end, [], lists:seq(3, 33)),
	ok.

test_anlyse_he_spread(_) ->
	ssqiu_server:start_link(),
	Seq = lists:foldl(fun(X,Accin) ->
						[{X,X}|Accin]
				end, [], lists:seq(0, 50)),
	RR=lists:foldl(fun(X,Acc0) ->
						RR = lists:foldl(fun(Mod,AccIn) ->
											V = ssq:auto_filter(he_spread,{X,Mod}),
							 				[V|AccIn]
									end, [], lists:seq(7, 70)),
						error_logger:info_msg("~p -- anlyse_he_spread_~p:~p~n", [?MODULE,X,ssq:anlyse2(RR)])
				   end, [],lists:reverse(Seq)),
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

%%use 2 to fliter odd-even
test_rem_he(_) ->
	ssqiu_server:start_link(),
	lists:foreach(fun(Rem) ->
		R = lists:foldl(fun(Mod,AccIn) ->
						V = ssqiu_server:auto_filter(rem_he, {Rem,Mod}),
						[V|AccIn]
				end, [], lists:seq(35, 70)),
						error_logger:info_msg("~p -- rem_he_~p result1:~p~n", [?MODULE,Rem,ssq:anlyse2(R)])
					end, [2,3,5,7]),
	ok.

test_link_he(_) ->
	ssqiu_server:start_link(),	
	RR = lists:foldl(fun(Mod,AccIn) ->
						V = ssqiu_server:auto_filter(link_he, Mod),
						[V|AccIn]
				end, [], lists:seq(7, 70)),
	error_logger:info_msg("~p -- link_he result:~p~n", [?MODULE,ssq:anlyse2(RR)]),
	ok.

test_zhishu(_) ->
	ssqiu_server:start_link(),	
	RR = lists:foldl(fun(Mod,AccIn) ->
						V = ssqiu_server:auto_filter(zhishu, Mod),
						[V|AccIn]
				end, [], lists:seq(7, 70)),
	error_logger:info_msg("~p -- zhishu result:~p~n", [?MODULE,ssq:anlyse2(RR)]),
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
	Reogr_Fun = fun(L,Part) ->
						Len = map(Part),
						R2 = lists:foldl(fun(Index,AccIn) ->
											R = lists:foldl(fun(L1,AccIn1) ->
																[lists:nth(Index, L1)|AccIn1]
														end, [], L),
											error_logger:info_msg("~p -- part_~p_~p result:~p~n", [?MODULE,Len,Index,ssq:anlyse2(R)])
									end, [],lists:seq(1, Len)) 
				end,
						
										
					
	Fun = fun(Part) ->
				  R = lists:foldl(fun(Mod,AccIn) ->
						V = ssqiu_server:auto_filter(part, {Part,Mod}),
						[V|AccIn]
				end, [], lists:seq(7, 70)),
				Reogr_Fun(R,Part)
		  end,
	lists:foreach(Fun, [5,6,8,11,16]),
	ok.

test_rem_same(_) ->
	ssqiu_server:start_link(),
	Reogr_Fun = fun(L,Part) ->
						R2 = lists:foldl(fun(Index,AccIn) ->
											R = lists:foldl(fun(L1,AccIn1) ->
																[lists:nth(Index, L1)|AccIn1]
														end, [], L),
											error_logger:info_msg("~p -- rem_~p count_~p result:~p~n", [?MODULE,Part,Index,ssq:anlyse2(R)])
									end, [],lists:seq(1, 6)) 
				end,
						
										
					
	Fun = fun(Part) ->
				  R = lists:foldl(fun(Mod,AccIn) ->
						V = ssqiu_server:auto_filter(rem_same, {Part,Mod}),
						[V|AccIn]
				end, [], lists:seq(7, 70)),
				Reogr_Fun(R,Part)
		  end,
	lists:foreach(Fun, [10,8]),
	ok.

test_he_rang_10(_) ->
	ssqiu_server:start_link(),	
	Fun = fun(Point) ->
				  R = lists:foldl(fun(Mod,AccIn) ->
						V = ssqiu_server:auto_filter(he_range, {Point,Mod}),
						[V|AccIn]
				end, [], lists:seq(7, 70)),
%% 				error_logger:info_msg("~p -- he_range_Point_~p result:~p~n", [?MODULE,Point,R]),
				error_logger:info_msg("~p -- he_range_Point_~p result:~p~n", [?MODULE,Point,ssq:anlyse2(R)])
		  end,
	
	lists:foreach(Fun, [60,70,80,90,100,110,120,130,140,150,160]),
	ok.

%%map() ->Part
map(5) ->
	6;
map(6) ->
	7;
map(8) ->
	9;
map(11) ->
	11;
map(16) ->
	16.
