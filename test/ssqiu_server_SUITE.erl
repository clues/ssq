%% Author: wave
%% Created: 2012-10-24
%% Description: TODO: Add description to ssqiu_server_SUITE
-module(ssqiu_server_SUITE).

-compile(export_all).
-define(ACTUAL_DATA,[2,7,8,17,21,28]).

all() ->[
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
		 {head,[3]},
%% 		 {med,[]},
		 {tail,[2]},
%% 		 {repeat_tongji,[1,2,0]},
		 {link,[3]},
		 {range_sum,{93,96}},
		 {jishu,[1,3,5]},
%% 		 {xiehao,[0,1,2,3,4]},
		 {he_012,[2]},
		 {include,[2]}
%% 		 {exclude,[2,12,15,23,24,32]}
%% 		 {exclude,[16,17,18, 7,8, 5,6,7,8]},
%% 		 {include,[4,5,6, 22,23,24, 3,4, 9,10, 15,16]}
%% 		 {yu,[7,21]}
		],
	
	lists:foreach(fun({Type,Value}) ->
						  ssqiu_server:temp(Type, Value) end, L),
	error_logger:info_msg("~p -- omg:~p~n", [?MODULE,ssqiu_server:get_omg()]),
	ok.

test_anlyse_repeat(_) ->
	ssqiu_server:start_link(),
	ssqiu_server:temp(repeat,ssq:auto_filter(repeat, 1)),
	ssqiu_server:temp(repeat,ssq:auto_filter(repeat, 2)),
	ssqiu_server:temp(repeat,ssq:auto_filter(repeat, 3)),
	ssqiu_server:temp(repeat,ssq:auto_filter(repeat, 4)),
	ssqiu_server:temp(repeat,ssq:auto_filter(repeat, 7)),
	ssqiu_server:temp(repeat,ssq:auto_filter(repeat, 9)),
	ssqiu_server:temp(repeat,ssq:auto_filter(repeat, 17)),
	ok.

test_anlyse_he_jishu(_) ->
	ssqiu_server:start_link(),
	
	L_HE_JISHU = [ssq:auto_filter(he_jishu,10),
				ssq:auto_filter(he_jishu,13),
				ssq:auto_filter(he_jishu,21),
				ssq:auto_filter(he_jishu,24),
				ssq:auto_filter(he_jishu,32),
				ssq:auto_filter(he_jishu,35),
				ssq:auto_filter(he_jishu,43),
				ssq:auto_filter(he_jishu,46),
				ssq:auto_filter(he_jishu,54),
				ssq:auto_filter(he_jishu,57),
				ssq:auto_filter(he_jishu,65),
				ssq:auto_filter(he_jishu,68)],
	
	HE_JISHU = case ssq:anlyse(L_HE_JISHU) of
		0 ->
			[1];
		1 ->
			[0];
		-1 ->
			[0,1]
	end,
	ssqiu_server:temp(he_jishu, HE_JISHU),
	ok.

test_anlyse_xiehao(_) ->
	ssqiu_server:start_link(),
	
	L_XIEHAO = [ssq:auto_filter(xiehao,10),
				ssq:auto_filter(xiehao,13),
				ssq:auto_filter(xiehao,21),
				ssq:auto_filter(xiehao,24),
				ssq:auto_filter(xiehao,32),
				ssq:auto_filter(xiehao,35),
				ssq:auto_filter(xiehao,43),
				ssq:auto_filter(xiehao,46),
				ssq:auto_filter(xiehao,54),
				ssq:auto_filter(xiehao,57),
				ssq:auto_filter(xiehao,65),
				ssq:auto_filter(xiehao,68)],
	%%10 - 20
	XIEHAO = case ssq:anlyse(L_XIEHAO) of
		0 ->
			[3,4,5,6];
		1 ->
			[0,1,2];
		-1 ->
			[0,1,2,3,4,5,6]
	end,
	ssqiu_server:temp(xiehao, XIEHAO),
	ok.

test_anlyse_tongji(_) ->
	ssqiu_server:start_link(),
	
	{RR1,RR2,RR3,RR4,RR5,RR6,RR7} = 
	lists:foldl(fun([R1,R2,R3,R4,R5,R6,R7],
					{L1,L2,L3,L4,L5,L6,L7}) ->
						{[R1|L1],[R2|L2],[R3|L3],[R4|L4],[R5|L5],[R6|L6],[R7|L7]}
				end, {[],[],[],[],[],[],[]}, 
							 [ssq:auto_filter(tongji,10),
							ssq:auto_filter(tongji,13),
				ssq:auto_filter(tongji,21),
				ssq:auto_filter(tongji,24),
				ssq:auto_filter(tongji,32),
				ssq:auto_filter(tongji,35),
				ssq:auto_filter(tongji,43),
				ssq:auto_filter(tongji,46),
				ssq:auto_filter(tongji,54),
				ssq:auto_filter(tongji,57),
				ssq:auto_filter(tongji,65),
				ssq:auto_filter(tongji,68),
				ssq:auto_filter(tongji,75)]),
	
	REPEAT = case ssq:anlyse(RR1) of
		0 ->
			[1,2,3,4,5,6];
		1 ->
			[0];
		-1 ->
			[0,1,2,3,4,5,6]
	end,
	ssqiu_server:add_case(repeat, REPEAT),
	
	
	LINK = case ssq:anlyse(RR2) of
			   0 ->
				   [2,3,4,5,6];
			   1 ->
				   [0];
			   -1 ->
				   [0,2,3,4,5,6]
		   end,
	ssqiu_server:add_case(link, LINK),
	
	TONGJI_LITTLE = case ssq:anlyse(RR3) of
			   0 ->
				   {60,99};
			   1 ->
				   {100,160};
			   -1 ->
				   {60,160}
		   end,
	ssqiu_server:add_case(range_sum, TONGJI_LITTLE),
	
	TONGJI_JISHU = case ssq:anlyse(RR4) of
			   0 ->
				   [3,4,5,6];
			   1 ->
				   [0,1,2,3];
			   -1 ->
				   [0,1,2,3,4,5,6]
		   end,
	ssqiu_server:add_case(jishu, TONGJI_JISHU),
	
	TONGJI_HEAD = case ssq:anlyse(RR5) of
			   0 ->
				   [3,4,5,6];
			   1 ->
				   [0,1,2,3];
			   -1 ->
				   [0,1,2,3,4,5,6]
		   end,
	ssqiu_server:add_case(head, TONGJI_HEAD),
	
	TONGJI_MED = case ssq:anlyse(RR6) of
			   0 ->
				   [3,4,5,6];
			   1 ->
				   [0,1,2,3];
			   -1 ->
				   [0,1,2,3,4,5,6]
		   end,
	ssqiu_server:add_case(med, TONGJI_MED),
	
	TONGJI_TAIL = case ssq:anlyse(RR7) of
			   0 ->
				   [3,4,5,6];
			   1 ->
				   [0,1,2,3];
			   -1 ->
				   [0,1,2,3,4,5,6]
		   end,
	
	ssqiu_server:add_case(tail, TONGJI_TAIL),
	ok.

%% no meaning
test_anlyse_yu(_) ->
	ssqiu_server:start_link(),
	RR=lists:foldl(fun(X,Acc0) ->
						L =[ 
						ssqiu_server:auto_filter(yu, {X,10}),
						ssqiu_server:auto_filter(yu, {X,20}),
						ssqiu_server:auto_filter(yu, {X,25}),
						ssqiu_server:auto_filter(yu, {X,30}),
						ssqiu_server:auto_filter(yu, {X,35}),
						ssqiu_server:auto_filter(yu, {X,40}),
						ssqiu_server:auto_filter(yu, {X,45}),
						ssqiu_server:auto_filter(yu, {X,50}),
						ssqiu_server:auto_filter(yu, {X,55}),
						ssqiu_server:auto_filter(yu, {X,60}),
						ssqiu_server:auto_filter(yu, {X,65}),
						ssqiu_server:auto_filter(yu, {X,71})],
						[{X,ssq:anlyse(L)}|Acc0]
						end, [], lists:seq(3, 33)),
	
	error_logger:info_msg("~p -- anlyse_yu:~p~n", [?MODULE,RR]),
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
								 {40,48}]),
	
	error_logger:info_msg("~p -- anlyse_he_spread:~p~n", [?MODULE,RR]),
	ok.	
