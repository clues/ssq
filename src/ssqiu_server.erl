%%% -------------------------------------------------------------------
%%% Author  : wave
%%% Description :
%%%
%%% Created : 2012-10-24
%%% -------------------------------------------------------------------
-module(ssqiu_server).

-behaviour(gen_server).
-include("ssq.hrl").
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(HISTORY_FILE,".ssq_history").
-define(RAW_FILE,".ssq_raw").
-define(LAST_FILE,".ssq_last").
-define(TEMP_FILE,".ssq_temp").
-define(TEST_PATH,"/home/clues/workspace/ssqiu").
-define(NUM_MEDIA,99).
%% --------------------------------------------------------------------
%% External exports
-export([start_link/0,
		 add_case/2,
		 get_cases/0,
		 get_state/0,
		 get_omg/0,
		 get/2,
		 get/3,
		 info_c/2,
		 info_r/2,
		 auto_filter/2,
		 temp/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {history=[],tongji=[],raw=[],temp=[],cases=[]}).

start_link() ->
	gen_server:start_link({local,?MODULE},?MODULE, [], []).
	
%% ====================================================================
%% External functions
%% ====================================================================


add_case(Type,Value) ->
	gen_server:cast(?MODULE, {add_case,{Type,Value}}).
get_cases() ->
	gen_server:call(?MODULE, get_cases).


%% weathe have list L,length less than 6
temp(rest,Step) ->
	gen_server:call(?MODULE, {temp,{rest,Step}});
temp(range,Range) ->
	gen_server:call(?MODULE, {temp,{range,Range}});

%% L = [0,1,2,3,4,5,6]
temp(repeat_tongji,L) ->
	gen_server:call(?MODULE, {temp,{repeat_tongji,L}});

temp(repeat,{{Min,Max},Mod}) ->
	gen_server:call(?MODULE, {temp,{repeat,{{Min,Max},Mod}}});

%%L = [0,2,3,4,5,6]
temp(link,L) ->
	gen_server:call(?MODULE, {temp,{link,L}});
%% Range = {ST,END}
temp(range_sum,Range) ->
	gen_server:call(?MODULE, {temp,{range_sum,Range}});
%% L = [0,1]
temp(he_jishu,L) ->
	gen_server:call(?MODULE, {temp,{he_jishu,L}});
%% L = [0,1,2]
temp(he_012,L) ->
	gen_server:call(?MODULE, {temp,{he_012,L}});
%% L = [1|2|3|4],only need to meet one
temp(xiehao,L) ->
	gen_server:call(?MODULE, {temp,{xiehao,L}});
%% only need to meet one
temp(exclude,L) ->
	gen_server:call(?MODULE, {temp,{exclude,L}});
%% need meet all
temp(include,L) ->
	gen_server:call(?MODULE, {temp,{include,L}});

%% need meet all
temp(part,[{ST,ED},{Min,Max}]) ->
	gen_server:call(?MODULE, {temp,{part,[{ST,ED},{Min,Max}]}});

temp(rem_he,{Rem,{Min,Max}}) ->
	gen_server:call(?MODULE, {temp,{rem_he,Rem,{Min,Max}}});

%% need meet all L = [1-33]
temp(yu,L) ->
	gen_server:call(?MODULE, {temp,{yu,L}});

%% L = [0,1,2,3,4,5,6]
temp(head,L) ->
	gen_server:call(?MODULE, {temp,{head,L}});
temp(med,L) ->
	gen_server:call(?MODULE, {temp,{med,L}});
temp(tail,L) ->
	gen_server:call(?MODULE, {temp,{tail,L}});
%% L = [0,1,2,3,4,5,6]
temp(jishu,L) ->
	gen_server:call(?MODULE, {temp,{jishu,L}}).

auto_filter(tongji,Mod) ->
	M1={Min1,Max1} = ssqiu_show:tongji(1, Mod),
	M2={Min2,Max2} = ssqiu_show:tongji(2, Mod),
	M3={Min3,Max3} = ssqiu_show:tongji(3, Mod),
	M4={Min4,Max4} = ssqiu_show:tongji(4, Mod),
	M5={Min51,Max51} = ssqiu_show:tongji(5, Mod),
	M6={Min52,Max52} = ssqiu_show:tongji(5,2,Mod),
	M7={Min53,Max53} = ssqiu_show:tongji(5,3,Mod),
	TJR=#tongji{repeat={Min1,Max1},neibo={Min2,Max2},little={Min3,Max3},
			jishu={Min4,Max4},head={Min51,Max51},med={Min52,Max52},tail={Min53,Max53}},	
	gen_server:call(?MODULE, {auto_filter,tongji,{Mod,TJR}},infinity);
auto_filter(he_jishu,Mod) ->
	{Min,Max} = ssqiu_show:sum_info(Mod),
	gen_server:call(?MODULE, {auto_filter,he_jishu,Mod,{Min,Max}});

auto_filter(repeat,Mod) ->
	{Min,Max} = ssqiu_show:repeat(Mod),
	{{Min,Max},Mod};

auto_filter(he_range,{Spoint,Mod}) ->
	gen_server:call(?MODULE, {auto_filter,he_range,{Spoint,Mod}});

auto_filter(he_spread,{Range,Mod}) ->
	gen_server:call(?MODULE, {auto_filter,he_spread,{Range,Mod}});

auto_filter(xiehao,Mod) ->
	{Min,Max} = ssqiu_show:xielink_ifno(Mod),
	gen_server:call(?MODULE, {auto_filter,xiehao,Mod,{Min,Max}});
auto_filter(yu,{Yu,Mod}) ->
	gen_server:call(?MODULE, {auto_filter,yu,{Yu,Mod}});

%% Part->captity 
%% 16->cap:2
%% 11->cap:3
%%  8->cap:4
%%  6->cap:5
%%  5->cap:6
auto_filter(part,{Part,Mod}) ->
	gen_server:call(?MODULE, {auto_filter,part,{Part,Mod}});

auto_filter(rem_he,{Rem,Mod}) ->
	gen_server:call(?MODULE, {auto_filter,rem_he,{Rem,Mod}});

auto_filter(he_012,Mod) ->
	[RR0,RR1,RR2] = ssqiu_server:info_r(he_012, Mod),
	{R0,R1,R2} = ssqiu_server:info_c(he_012, Mod-1),
	[{R0,RR0,Mod},{R1,RR1,Mod},{R2,RR2,Mod}];

auto_filter(shake,Mod) ->
	Range = ssqiu_show:shake_info(Mod),
	Base = ssqiu_server:info_c(shake, Mod-1),
	gen_server:call(ssqiu_server, {auto_filter,shake,{Range,Base,Mod}}).	


get_omg() ->
	gen_server:call(?MODULE, get_omg).
get_state() ->
	gen_server:call(?MODULE, get_state).

get(baohan,L,Raw) ->
	gen_server:call(?MODULE, {get_baohan,L,Raw}).
get(baohan,L) ->
	gen_server:call(?MODULE, {get_baohan,L});
get(link,N) ->
	gen_server:call(?MODULE, {get_link,N}).

info_c(shake,Mod) ->
	gen_server:call(?MODULE, {info_c,shake,Mod});
info_c(he_012,Mod) ->
	gen_server:call(?MODULE, {info_c,he_012,Mod}).

info_r(he_012,Mod) ->
	gen_server:call(?MODULE, {info_r,he_012,Mod}).


init([]) ->
	{History,Tongji} = load_from_file(filename:join(?TEST_PATH,?HISTORY_FILE)),
	error_logger:info_msg("~p -- loaded ~p record from history file,the last record is:~p~n", [?MODULE,length(History),hd(History)]),
	case filelib:is_file(filename:join(?TEST_PATH,?RAW_FILE)) of
		true ->
			ignored;
		false ->
			ssq:init_raw_file(?TEST_PATH)
	end,
	Raw = case filelib:is_file(filename:join(?TEST_PATH, ?LAST_FILE)) of
			  false ->
				  ssq:load_raw_data(filename:join(?TEST_PATH, ?RAW_FILE));
			  true ->
				  ssq:load_raw_data(filename:join(?TEST_PATH, ?LAST_FILE))
		  end,
	error_logger:info_msg("~p -- load raw file success(~p)~n", [?MODULE,length(Raw)]),
    {ok, #state{history=History,tongji=Tongji,raw=Raw,temp=[Raw]}}.


handle_call(get_omg, From, #state{temp=TP}=State) ->
	{reply, {length(hd(TP)),hd(TP)}, State};

handle_call(get_state, From, State) ->
	{reply, {ok,State}, State};

handle_call(get_cases, From, #state{cases=Cases}=State) ->
	{reply, {ok,Cases}, State};

handle_call({temp,{rest,Step}}, From, #state{history=History,raw=Raw,tongji=TJ,temp=TP}=State) ->
	Tp1 = local_list_rest(Step,TP,Raw),
	First = hd(Tp1),
	{reply, {length(Tp1)-1,length(First),First}, State#state{temp=[Raw]}};

handle_call({temp,{range,Range}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	RR = lists:foldl(fun(H,AccIn) ->
						V = lists:foldl(fun(X,{A,B,C}) ->
											if
												1 =< X,X =< 11 ->
													{A+1,B,C};
												12 =< X, X =< 22 ->
													{A,B+1,C};
												true ->
													{A,B,C+1}
											end
									end, {0,0,0}, H),
						if
							V == Range ->
								[H|AccIn];
							true ->
								AccIn
						end
				end, [], hd(TP)),
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{range_sum,{ST,EN}}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	RR = lists:foldl(fun(H,AccIn) ->
						Sum = lists:sum(H),
						if
							ST =< Sum, Sum =< EN ->
								[H|AccIn];
							true ->
								AccIn
						end
				end, [], hd(TP)),
	error_logger:info_msg("~p [TONGJI_SUM]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),{ST,EN}]),	
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{he_jishu,L}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	RR = lists:foldl(fun(H,AccIn) ->
						Sum = lists:sum(H),
						Tag = lists:member(Sum rem 2, L),
						if
							Tag  ->
								[H|AccIn];
							true ->
								AccIn
						end
				end, [], hd(TP)),
	error_logger:info_msg("~p [HE_JISHU]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),L]),
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{include,L}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	RR = lists:foldl(fun(H,AccIn) ->
							S=lists:foldl(fun(X,AccIn0) ->
												Tag = lists:member(X, L),
												if
													Tag ->
														AccIn0+1;
													true ->
														AccIn0
												end
										end,0 , H),
							if
								S == length(L) ->
									[H|AccIn];
								true ->
									AccIn
							end							
				end, [], hd(TP)),
	error_logger:info_msg("~p [INCLUDE]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),L]),		
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{part,[{Rang1,Rang2},{Min,Max}]}=Con}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	RR = lists:foldl(fun(H,AccIn) ->
							N = lists:foldl(fun(X,AccIn) ->
												if
													Rang1 =< X,X =< Rang2 ->
														AccIn+1;
													true ->
														AccIn
												end
										end, 0, H), 
							if
								Min =< N,N =< Max ->
									[H|AccIn];
								true ->
									AccIn
							end						
				end, [], hd(TP)),
	error_logger:info_msg("~p [PART]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),Con]),	
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{rem_he,Rem,{Min,Max}}=Con}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	RR = lists:foldl(fun(H,AccIn) ->
							Sum = lists:sum(H),
							Val = Sum rem Rem,
							if
								Min =< Val,Val =< Max ->
									[H|AccIn];
								true ->
									AccIn
							end			
				end, [], hd(TP)),
	error_logger:info_msg("~p [REM_HE]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),Con]),	
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{yu,L}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	RR = lists:foldl(fun(H,AccIn) ->
							N=lists:foldl(fun(Y,A) ->
											S=lists:foldl(fun(X,AccIn0) ->
																if
																	X rem Y == 0 ->
																		AccIn0+1;
																	true ->
																		AccIn0
																end
													  		end,0 , H),
											if
												S > 0 ->
													A+1;
												true ->
													A
										 	end
										end, 0, L),

							if
								N == length(L) ->
									[H|AccIn];
								true ->
									AccIn
							end							
				end, [], hd(TP)),
	error_logger:info_msg("~p [YU]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),L]),	
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{exclude,L}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	RR = lists:foldl(fun(H,AccIn) ->
							S=lists:foldl(fun(X,AccIn0) ->
												Tag = lists:member(X, L),
												if
													Tag ->
														AccIn0+1;
													true ->
														AccIn0
												end
										end,0 , H),
							if
								S == 0 ->
									[H|AccIn];
								true ->
									AccIn
							end
				end, [], hd(TP)),
	
	error_logger:info_msg("~p [EXCLUDE]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),L]),	
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{xiehao,[]}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	RR = hd(TP),
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{xiehao,L}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	{_,Old} = hd(History),
	RR = lists:foldl(fun(H,AccIn) ->
							S=local_xiehao_info(H, Old, 0), 
							Tag = lists:member(S, L),
							if
								Tag ->
									[H|AccIn];
								true ->
									AccIn
							end
				end, [], hd(TP)),
	error_logger:info_msg("~p [XIE_HAO]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),L]),	
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{he_012,L}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	RR = lists:foldl(fun(H,AccIn) ->
						Sum = lists:sum(H),
						Tag = lists:member(Sum rem 3, L),
						if
							Tag ->
								[H|AccIn];
							true ->
								AccIn
						end
				end, [], hd(TP)),
	error_logger:info_msg("~p [HE_012]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),L]),		
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{jishu,L}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	RR = lists:foldl(fun(H,AccIn) ->
						JI=lists:foldl(fun(X,AccIn) ->
											if
												X rem 2 == 1 ->
													AccIn+1;
												true ->
													AccIn
											end
									end, 0, H),
						TAG = lists:member(JI, L),
						if
							TAG ->
								[H|AccIn];
							true ->
								AccIn
						end
				end, [], hd(TP)),
	error_logger:info_msg("~p [TONGJI_JISHU]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),L]),					 					
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{head,L}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	RR = lists:foldl(fun(H,AccIn) ->
						N = lists:foldl(fun(X,Acc0) ->
											if
												X =< 11 ->
													Acc0 + 1;
												true ->
													Acc0
											end
									end, 0, H),
						TAG = lists:member(N, L),
						if
							TAG ->
								[H|AccIn];
							true ->
								AccIn
						end
				end, [], hd(TP)),
	error_logger:info_msg("~p [TONGJI_HEAD]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),L]),					 					
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{med,L}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	RR = lists:foldl(fun(H,AccIn) ->
						N = lists:foldl(fun(X,Acc0) ->
											if
												12 =< X,X =< 22 ->
													Acc0 + 1;
												true ->
													Acc0
											end
									end, 0, H),
						TAG = lists:member(N, L),
						if
							TAG ->
								[H|AccIn];
							true ->
								AccIn
						end
				end, [], hd(TP)),
	error_logger:info_msg("~p [TONGJI_MED]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),L]),					 					
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{tail,L}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	RR = lists:foldl(fun(H,AccIn) ->
						N = lists:foldl(fun(X,Acc0) ->
											if
												23 =< X ->
													Acc0 + 1;
												true ->
													Acc0
											end
									end, 0, H),
						TAG = lists:member(N, L),
						if
							TAG ->
								[H|AccIn];
							true ->
								AccIn
						end
				end, [], hd(TP)),
	error_logger:info_msg("~p [TONGJI_TAIL]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),L]),					 					
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{link,L}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	RR = lists:foldl(fun(H,AccIn) ->
						 X = local_call_link_num(H),
						 case lists:member(X, L) of
							 true ->
								 [H|AccIn];
							 false ->
								 AccIn
						 end
				end, [], hd(TP)),
	error_logger:info_msg("~p [TONGJI_LINK]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),L]),					 					 
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({temp,{repeat_tongji,L}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	{_,Old} = hd(History),
	RR = lists:foldl(fun(H,AccIn) ->
						 N = lists:foldl(fun(X,Acc0) ->
											 Flag = lists:member(X, Old),
											 if
												 Flag ->
													 Acc0+1;
												 true ->
													 Acc0
											 end
									 end, 0, H),
						 Tag = lists:member(N, L),
						 if
							 Tag ->
								 [H|AccIn];
							 true ->
								 AccIn
						 end
				end, [], hd(TP)),
	error_logger:info_msg("~p [TONGJI_REPEAT]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),L]),					 
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};


handle_call({temp,{repeat,{{Min,Max},Mod}}}, From, #state{history=History,temp=TP,tongji=TJ}=State) ->	
	Meger = lists:foldl(fun({_,Intl},Acc0) ->
						lists:foldl(fun(X,Acc1) ->
											Tag = lists:member(X, Acc1),
											if
												Tag ->
													Acc1;
												true ->
													[X|Acc1]
											end
									end, Acc0, Intl)
						end, [], lists:sublist(History,1, Mod)),
	
	RR = lists:foldl(fun(H,AccIn) ->
						 N = lists:foldl(fun(X,Acc0) ->
											 Flag = lists:member(X, Meger),
											 if
												 Flag ->
													 Acc0+1;
												 true ->
													 Acc0
											 end
									 end, 0, H),
						 if
							 Min =< N,N =< Max ->
								 [H|AccIn];
							 true ->
								 AccIn
						 end
				end, [], hd(TP)),
	error_logger:info_msg("~p [REPEAT]-- check out ~p from ~p,when case:~p", [?MODULE,
																	  length(RR),
																	  length(hd(TP)),{Mod,{Min,Max}}]),					 
	{reply, {length(TP),length(RR),RR}, State#state{temp=[RR|TP]}};

handle_call({info_c,shake,Mod}, From, #state{history=History,raw=Raw,tongji=TJ}=State) ->
	[[_,_,N1,_,_]|T] = TJ,
	{_,V1,V2} = lists:foldl(fun([_,_,N2,_,_],{N3,Shake1,Shake2}) ->
					S1 = if
						N2 =< ?NUM_MEDIA ,N3 > ?NUM_MEDIA ->
							Shake1 + 1;
						N2 > ?NUM_MEDIA ,N3 =< ?NUM_MEDIA ->
							Shake1 + 1;
						true ->
							Shake1
					end,
					S2 = if
						N2 rem 2 =/= N3 rem 2 ->
							Shake2 +1;
						true ->
							Shake2
					end,
					{N2,S1,S2} end, {N1,0,0}, lists:sublist(T, Mod-1)),
	{reply,{V1,V2}, State};

handle_call({info_c,he_012,Mod}, From, #state{history=History,raw=Raw,tongji=TJ}=State) ->
	FUN_RANGE = fun(L) ->
						NL = lists:foldl(fun([_,_,N,_,_],AccIn) ->
											[N|AccIn] end, [], L),
						local_012_info(NL, {0,0,0})
				end,
	{reply,FUN_RANGE(lists:sublist(TJ, Mod)), State};

handle_call({info_r,he_012,Mod}, From, #state{history=History,raw=Raw,tongji=TJ}=State) ->
	MaxIndex = length(TJ) - Mod + 1,
	FUN_RANGE = fun(L) ->
						NL = lists:foldl(fun([_,_,N,_,_],AccIn) ->
											[N|AccIn] end, [], L),
						local_012_info(NL, {0,0,0})
				end,
	
	{A,B,C} = lists:foldl(fun(Index,{RL1,RL2,RL3}) ->
						{R1,R2,R3} = FUN_RANGE(lists:sublist(TJ, Index,Mod)),
						{[R1|RL1],[R2|RL2],[R3|RL3]} end, {[],[],[]}, lists:seq(1, MaxIndex)),
	
	{reply,[{lists:min(A),lists:max(A)},
			{lists:min(B),lists:max(B)},
			{lists:min(C),lists:max(C)}], State};

handle_call({get_baohan,L,LI}, From, #state{history=History,raw=Raw,tongji=TJ}=State) ->
	RR = lists:foldl(fun(H,Acc) ->
						Accunt = lists:foldl(fun(X,Acc0) ->
											Tag = lists:member(X, H),
											if
												Tag ->
													Acc0+1;
												true ->
													Acc0
											end
									end,0 , L),
						if
							Accunt == length(L) ->
								[H|Acc];
							true ->
								Acc
						end
				end, [], LI),

	{reply, {length(RR),RR}, State};

handle_call({get_baohan,L}, From, #state{history=History,raw=Raw,temp=TP,tongji=TJ}=State) ->
	RR = lists:foldl(fun(H,Acc) ->
						Accunt = lists:foldl(fun(X,Acc0) ->
											Tag = lists:member(X, H),
											if
												Tag ->
													Acc0+1;
												true ->
													Acc0
											end
									end,0 , L),
						if
							Accunt == length(L) ->
								[H|Acc];
							true ->
								Acc
						end
				end, [], hd(TP)),
	{reply, {length(RR),RR}, State};

handle_call({get_link,N}, From, #state{history=History,raw=Raw,tongji=TJ}=State) ->
	RR = lists:foldl(fun(H,AccIn) ->
						 Tag = lists:member(N, local_call_link_num(H,[])),
						 if
							 Tag ->
								 [H|AccIn];
							 true ->
								 AccIn
						 end
				end, [], Raw),

	{reply,{length(RR),RR}, State};



handle_call({call,merge}, From, #state{history=History,raw=Raw,tongji=TJ}=State) ->
	RR = lists:foldl(fun(H,AccIn) ->
						lists:foldl(fun(X,Acc) ->
											case lists:member(X, Acc) of
												true ->
													Acc;
												false ->
													[X|Acc]
											end
									end, AccIn, H)
				end, [], Raw),
	{reply, RR, State};

handle_call({auto_filter,shake,{[{LT1,LT2},{JS1,JS2}],{LT,JS},Mod}}, From, #state{history=History,raw=Raw,tongji=TJ}=State) ->
	{_,Old} = hd(History),
	Sum = lists:sum(Old),
	TAG = Sum rem 2,
	{reply, [{LT,{LT1,LT2},Mod},{JS,{JS1,JS2},Mod}], State};

handle_call({auto_filter,yu,{Yu,Mod}}, From, #state{history=History,raw=Raw,tongji=TJ}=State) ->
	Fun_One = fun(L,AccIn) ->
				  lists:foldl(fun(X,AccIn0) ->
									  if 
										 X rem Yu ==0 ->
											 AccIn0+1;
										 true ->
											 AccIn0
									  end
							  end, AccIn, L)
			  end,

	Fun_Range = fun(L) ->
				  lists:foldl(fun({_,Intl},Acc0) ->
							  		 Fun_One(Intl,Acc0)
									 end ,0, L)
				end,
	
	MaxIndex = length(History) - Mod+1,
	RR1 = lists:foldl(fun(Index,Acc0)->
						ModL = lists:sublist(History, Index,Mod),
						Value = Fun_Range(ModL),
						[Value|Acc0]
					end, [], lists:seq(1, MaxIndex)),
	Range={Min,Max} = {lists:min(RR1),lists:max(RR1)},
	CurrntValue = Fun_Range(lists:sublist(History, Mod-1)),
	{reply, {CurrntValue,Range,Yu,Mod}, State};

handle_call({auto_filter,rem_he,{Rem,Mod}}, From, #state{history=History,raw=Raw,tongji=TJ}=State) ->
	    
	Fun_Range = fun(L) ->
				  lists:foldl(fun([_,_,Sum,_,_],Acc0) ->
							  		 Val = Sum rem Rem,
									 Val+Acc0
									 end ,0, L)
				end,
	
	MaxIndex = length(TJ) - Mod+1,
	RR1 = lists:foldl(fun(Index,Acc0)->
						ModL = lists:sublist(TJ, Index,Mod),
						Value = Fun_Range(ModL),
						[Value|Acc0]
					end, [], lists:seq(1, MaxIndex)),
	Range={Min,Max} = {lists:min(RR1),lists:max(RR1)},
	CurrntValue = Fun_Range(lists:sublist(TJ, Mod-1)),
	{reply, {CurrntValue,Range,Rem,Mod}, State};

handle_call({auto_filter,xiehao,Mod,{Min,Max}}, From, #state{history=History,raw=Raw,tongji=TJ}=State) ->
	   Based = lists:foldl(fun(Index,Acc) ->
						Old = element(2,lists:nth(Index+1, History)),
						lists:foldl(fun(X1,AccIn) ->
											IS_HIG = lists:member(X1+1, Old),
											IS_LOW = lists:member(X1-1, Old),
											if
												IS_HIG , IS_LOW ->
													AccIn +2;
												IS_HIG orelse IS_LOW ->
													AccIn + 1;
												true ->
													AccIn
											end	
									end, Acc, element(2,lists:nth(Index, History))) 
					end, 0, lists:seq(1, Mod-1)),
	{reply, {Based,{Min,Max},Mod}, State};



handle_call({auto_filter,part,{Part,Mod}}, From, #state{history=History,raw=Raw,tongji=TJ}=State) ->
	Len = 33 div Part,
	
	%% init
	FUN_INIT = fun() ->				   
		lists:foreach(fun(X) ->
							Name = list_to_atom(lists:concat(["part",X])),
							put(Name,[]),
						  	put(X,0)
				  	end, lists:seq(1, 16))
		end,
	
	FUN_INIT(),
	FUN_ONE = fun(L) ->
					  lists:foldl(fun(X,Acc0) ->
										  if
											  0 < X,X =< Len ->
												  put(1,get(1)+1);
											  1*Len < X, X =< 2*Len ->
												  put(2,get(2)+1);
											  2*Len < X, X =< 3*Len ->
												  put(3,get(3)+1);
											  3*Len < X, X =< 4*Len ->
												  put(4,get(4)+1);
											  4*Len < X, X =< 5*Len ->
												  put(5,get(5)+1);
											  5*Len < X, X =< 6*Len ->
												  put(6,get(6)+1);
											  6*Len < X, X =< 7*Len ->
												  put(7,get(7)+1);
											  7*Len < X, X =< 8*Len ->
												  put(8,get(8)+1);
											  8*Len < X, X =< 9*Len ->
												  put(9,get(9)+1);
											  9*Len < X, X =< 10*Len ->
												  put(10,get(10)+1);
											  10*Len < X, X =< (11*Len) ->
										  		  put(11,get(11)+1);
											  11*Len < X, X =< (12*Len) ->
										  		  put(12,get(12)+1);
											  12*Len < X, X =< (13*Len) ->
										  		  put(13,get(13)+1);
											  13*Len < X, X =< (14*Len) ->
										  		  put(14,get(14)+1);
											  14*Len < X, X =< (15*Len) ->
										  		  put(15,get(15)+1);										  
											  true ->
												  put(16,get(16)+1)
										  end
									end, [], L)
			  end,
	
	FUN_RANGE = fun(Range,AccIn) ->
						lists:foldl(fun({_,Intl},AccIn0) ->
											FUN_ONE(Intl)
									end, AccIn, Range)
				end,
	
	MaxIndex = length(History) - Mod+1,
	lists:foldl(fun(Index,AccIn) ->
						SubList = lists:sublist(History, Index,Mod),
						FUN_RANGE(SubList,0),
						lists:foreach(fun(X) ->
									Name = list_to_atom(lists:concat(["part",X])),
									put(Name,[get(X)|get(Name)]),
									put(X,0)
									end, lists:seq(1, 16))
				end, [], lists:seq(1, MaxIndex)),
	
	CurrentValue = FUN_RANGE(lists:sublist(History, Mod-1),0),
	R = lists:foldl(fun(X,AccIn) ->
						Name = list_to_atom(lists:concat(["part",X])),
						L = get(Name),
						[{get(X),{lists:min(L),lists:max(L)},Mod}|AccIn]
						end, [], lists:seq(1, 16)),	
	{reply, lists:reverse(R), State};

handle_call({auto_filter,he_range,{Spoint,Mod}}, From, #state{history=[{_,Last}|_T],raw=Raw,tongji=TJ}=State) ->
	Start = Spoint - 9,
	FUN_RANGE = fun(Range,AccIn) ->
						lists:foldl(fun([_,_,N,_,_],AccIn0) ->
											if
												Start =< N,N =< Spoint ->
													AccIn0+1;
												true ->
													AccIn0
											end
									end, AccIn, Range) end,
	MaxIndex = length(TJ) - Mod+1,
	R1 = lists:foldl(fun(Index,AccIn) ->
						SubList = lists:sublist(TJ, Index,Mod),
						R = FUN_RANGE(SubList,0),
						[R | AccIn]
				end, [], lists:seq(1, MaxIndex)),
	{Min,Max}=R2 = {lists:min(R1),lists:max(R1)},
	CurrentValue = FUN_RANGE(lists:sublist(TJ, Mod-1),0),
	{reply, {CurrentValue,R2,Spoint,Mod}, State};

handle_call({auto_filter,he_spread,{{Min,Max},Mod}}, From, #state{history=[{_,Last}|_T],raw=Raw,tongji=TJ}=State) ->
	FUN_RANGE = fun(Range,AccIn) ->
						lists:foldl(fun([_,_,N,_,_],AccIn0) ->
											ABS = erlang:abs(N-99),
											if
												Min =< ABS,ABS =< Max ->
													AccIn0+1;
												true ->
													AccIn0
											end
									end, AccIn, Range) end,
	MaxIndex = length(TJ) - Mod+1,
	R1 = lists:foldl(fun(Index,AccIn) ->
						SubList = lists:sublist(TJ, Index,Mod),
						R = FUN_RANGE(SubList,0),
						[R | AccIn]
				end, [], lists:seq(1, MaxIndex)),
	R2 = {lists:min(R1),lists:max(R1)},
	CurrentValue = FUN_RANGE(lists:sublist(TJ, Mod-1),0),
	{reply, {CurrentValue,R2,{Min,Max},Mod}, State};

handle_call({auto_filter,he_jishu,Mod,{Min,Max}}, From, #state{history=[{_,Last}|_T],raw=Raw,tongji=TJ}=State) ->
	Ed = lists:foldl(fun([_,_,N,_,_],AccIn) ->
						case N rem 2 of
							1 ->
								AccIn+1;
							_ ->
								AccIn
						end
				end, 0, lists:sublist(TJ, Mod-1)),
	{reply, {Ed,{Min,Max},Mod}, State};

handle_call({auto_filter,tongji,{Mod,Range}}, From, #state{history=[{_,Last}|_T],raw=Raw,tongji=TJ}=State) ->
	Tongjied = lists:foldl(fun([N1,N2,N3,{N4,_},{N51,N52,N53}],#tongji{repeat=RP}=Tonji) ->
						#tongji{neibo=NB}=Tonji1 = case N1 of
									0 ->
										Tonji;
									_ ->
										Tonji#tongji{repeat=RP+1}
								 end,
						#tongji{little=LT}=Tonji2 = case N2 of
									 0 ->
										 Tonji1;
									 _ ->
										 Tonji1#tongji{neibo=NB+1}
								 end,
						#tongji{jishu=JS}=Tonji3 = if
									 N3 =< ?NUM_MEDIA ->
										 Tonji2#tongji{little=LT+1};
									 true ->
										 Tonji2
								 end,
						#tongji{head=HD,med=MD,tail=TL} =Tonji4= Tonji3#tongji{jishu=JS+N4},
						Tonji4#tongji{head=HD+N51,med=MD+N52,tail=TL+N53}
				end, #tongji{},lists:sublist(TJ,Mod-1)),
	put(last_data,Last),

	{reply, [{Tongjied#tongji.repeat,Range#tongji.repeat,Mod},
			 {Tongjied#tongji.neibo,Range#tongji.neibo,Mod},
			 {Tongjied#tongji.little,Range#tongji.little,Mod},
			 {Tongjied#tongji.jishu,Range#tongji.jishu,Mod},
			 {Tongjied#tongji.head,Range#tongji.head,Mod},
			 {Tongjied#tongji.med,Range#tongji.med,Mod},
			 {Tongjied#tongji.tail,Range#tongji.tail,Mod}], State};

handle_call({get_history,all}, From, #state{history=H}=State) ->
	Reply = H,
    {reply, {ok,Reply}, State};
handle_call({get_history,Range}, From, #state{history=H}=State) ->
	Reply = lists:sublist(H, Range),
    {reply, {ok,Reply}, State};

handle_call({get_tongji,all}, From, #state{tongji=H}=State) ->
	Reply = H,
    {reply, {ok,Reply}, State};
handle_call({get_tongji,Range}, From, #state{tongji=H}=State) ->
	Reply = lists:sublist(H, Range),
    {reply, {ok,Reply}, State};

handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% -------------------------------------------------------------------
handle_cast(rest_temp, #state{raw=Raw}=State) ->
	error_logger:info_msg("~p -- rest temp ok~n",[?MODULE]),
    {noreply, State#state{temp=Raw}};


handle_cast({add_case,{K,V}=Case}, #state{cases=CASES}=State) ->
	T1 = case lists:keyfind(K, 1, CASES) of
		false ->
			[Case|CASES];
		_ ->
			lists:keyreplace(K, 1, CASES, Case)
	end,
    {noreply, State#state{cases=T1}};


handle_cast(Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------


load_from_file(File) ->
	error_logger:info_msg("path::::::~p~n", [File]),
	{ok,Io} = file:open(File, [read]),
	loop_read_history(Io,[],[]).

loop_read(Io,Rest) ->
	case file:read_line(Io) of
		{ok,Data} ->
			Lstr = string:tokens(Data, " \n"),
			[Seqno|Lint] = lists:foldr(fun(X,AccIn) ->
								[list_to_integer(X)|AccIn] end, [], Lstr),
			loop_read(Io,[{Seqno,Lint}|Rest]);
		_ ->
			Rest
	end.

loop_read_history(Io,R1,R2) ->
	case file:read_line(Io) of
		{ok,Data} ->
			Lstr = string:tokens(Data, " \t"),
			[Seqno|Lint] = lists:foldr(fun(X,AccIn) ->
								[list_to_integer(X)|AccIn] end, [], lists:sublist(Lstr, 7)),			
%% 			error_logger:info_msg("~p~n",[Lint]),
			Tongji = lists:foldr(fun(X,AccIn) ->
								R =case string:tokens(X, ":") of
									[H] ->
										list_to_integer(H);
									[H,B] ->
										{list_to_integer(H),list_to_integer(B)};
									[H,B,C] ->
										{list_to_integer(H),list_to_integer(B),hd(C)-48}
								end,
								[R|AccIn] end, [], lists:sublist(Lstr, 15,5)),				
			loop_read_history(Io,[{Seqno,Lint}|R1],[Tongji|R2]);
		_ ->
			{R1,R2}
	end.	
			
save_and_print(RR,Raw) ->
	error_logger:info_msg("~p -- check out ~p record from ~p records(del:~p) at:~p~n", [?MODULE,length(RR),
																				length(Raw),
																		  length(Raw) -length(RR),
																		  time()]),
    file:write_file(filename:join(?TEST_PATH, ?LAST_FILE), RR),
	ok.

local_call_link_num(L) ->
	local_call_link_num(L,[]).
local_call_link_num(L,R) when length(L) == 1 ->
	Sum = lists:sum(R),
	case Sum of
		0 ->
			0;
		5 ->
			6;
		1 ->
			2;
		2 when R == [1,1,0,0,0];R == [0,1,1,0,0];R == [0,0,1,1,0];R == [0,0,0,1,1]->
			3;
		2 ->
			4;
		3 when R == [1,0,1,0,1]->
			6;
		3 when R == [1,1,1,0,0];R == [0,1,1,1,0];R == [0,0,1,1,1]->
			4;
		3 ->
			5;
		4 when R == [1,1,1,0,1];R == [1,0,1,1,1];R == [1,1,0,1,1]->
			6;
		4 ->
			5
	end;	
		
local_call_link_num([H|T],R) ->
	if
		H+1 == hd(T) ->
			local_call_link_num(T,[1|R]);
		true ->
			local_call_link_num(T,[0|R])
	end.

local_list_rest(0,Temp,Src) ->
	[Src];
local_list_rest(Step,Temp,Src) ->
	Len = length(Temp),
	if
		Len =< Step ->
			Temp;
		true ->
			lists:nthtail(Len-Step, Temp)
	end.
local_012_info([],R) ->
	R;
local_012_info([H|T],{R1,R2,R3}) ->
	RE=if
		H rem 3 == 0 ->
			{R1+1,R2,R3};
		H rem 3 == 1 ->
			{R1,R2+1,R3};
		true ->
			{R1,R2,R3+1}
	end,
	local_012_info(T,RE).

local_xiehao_info([],Old,AccIn) ->
	AccIn;
local_xiehao_info([X|T],Old,AccIn) ->
										IS_HIG = lists:member(X+1, Old),
										IS_LOW = lists:member(X-1, Old),
										S=if
											IS_HIG , IS_LOW ->
												AccIn +2;
											IS_HIG orelse IS_LOW ->
												AccIn + 1;
											true ->
												AccIn
										end	,
	local_xiehao_info(T,Old,S).
		
		