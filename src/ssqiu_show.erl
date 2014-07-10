%% Author: wave
%% Created: 2012-10-24
%% Description: TODO: Add description to ssqiu_show
-module(ssqiu_show).

-export([mod/2,
		 hot/1,
		 tongji/2,
		 tongji/3,
		 repeat/1,
		 sum_info/1,
		 shake_info/1,
		 link_info/1,
		 xielink_ifno/1]).


mod(Last,Mod) ->
	{ok,Data} = gen_server:call(ssqiu_server, {get_history,Last}),
	lists:foreach(fun(X) -> put(X,0) end, lists:seq(0, Mod-1)),
	lists:foreach(fun({Seq,Lint}) ->
							lists:foreach(fun(X) -> 
						 			V = X rem Mod,
									Old = get(V),
									put(V,Old+1)
				  							end
				  			, Lint),
							io:format("~n~p   ",[Seq]),
							lists:foreach(fun(X) ->
												  case get(X) of
													  0 ->
														  io:format("-  ");
													  N ->
														  io:format("~p  ",[N])
												  end,
												  put(X,0)
										  end,
												  lists:seq(0, Mod-1))
				  		end						  
				  , Data),

	ok.

hot(Last) ->
	{ok,Data} = gen_server:call(ssqiu_server, {get_history,Last}),
	lists:foreach(fun(X) ->put(X,0) end, lists:seq(1, 33)),
	lists:foreach(fun({Seq,Lint}) ->
						  lists:foreach(fun(X) ->
												put(X,get(X)+1) end, Lint) end, Data),
	L = lists:foldl(fun(X,AccIn) ->[{X,get(X)}|AccIn] end, [], lists:seq(1, 33)),
	L1 = lists:sort(fun({A,N1},{B,N2}) ->
					   N1 >= N2 end,L),
	lists:foreach(fun({X,V}) ->
						  io:format("~n  ~p: ~p", [X,V]) end, L1),
	ok.

tongji(Seqno,Mod) ->
	tongji(Seqno,1,Mod).
tongji(Seqno,SubSeqno,Mod) ->
	{ok,Data} = gen_server:call(ssqiu_server, {get_tongji,all}),
	{Min,Max} = tongji_loop(Data,1,Seqno,SubSeqno,Mod,[]).

tongji_loop(Data,Index,Seqno,SubSeqno,Mod,R) when length(Data)+2 == Index+Mod ->
	{lists:min(R),lists:max(R)};
tongji_loop(Data,Index,Seqno,SubSeqno,Mod,R) ->
	L =lists:sublist(Data, Index, Mod),
	Sum = lists:foldl(fun(X,AccIn) when Seqno =< 2->
						case lists:nth(Seqno, X) of
							0 ->
								AccIn;
							_ ->
								AccIn+1
						end;
						 (X,AccIn) when Seqno == 3 ->
							  Little = lists:nth(Seqno, X),
							  if
								  Little =< 99 ->
									  AccIn +1;
								  true ->
									  AccIn
							  end;
						 (X,AccIn) when Seqno == 4 ->
							  {Ji,_} = lists:nth(Seqno, X),
							  AccIn + Ji;
						 (X,AccIn) when Seqno == 5 ->
							  AccIn + element(SubSeqno,lists:nth(Seqno, X))
				end, 0, L),
	tongji_loop(Data,Index+1,Seqno,SubSeqno,Mod,[Sum|R]).


repeat(Skip) ->
	{ok,Data} = gen_server:call(ssqiu_server, {get_history,all}),
	repeat_loop(Data,Skip,[]).
repeat_loop(Data,Range,RR) when length(Data) == Range->
	{lists:min(RR),lists:max(RR)};
repeat_loop([{_,H}|T],Range,RR) ->

	R = lists:foldl(fun({_,X},AccIn) ->
						lists:foldl(fun(X1,AccIn1) ->
											Tag = lists:member(X1, AccIn1),
											if
												Tag ->
													AccIn1;
												true ->
													[X1|AccIn1] 
											end
									end, AccIn, X) 
					end, [], lists:sublist(T, Range)),
	
	S = lists:foldl(fun(U,Sum) ->
						Tag = lists:member(U, R),
						if
							Tag ->
								Sum+1;
							true ->
								Sum
						end
				end,0, H),
	
	repeat_loop(T,Range,[S|RR]).

sum_info(Mod) ->  %%30
	{ok,Data} = gen_server:call(ssqiu_server, {get_tongji,all}),
	sum_info(Data,Mod,[]).

sum_info(Data,Mod,R) when length(Data) < Mod ->
	{lists:min(R),lists:max(R)};
sum_info(Data,Mod,R) ->
	S=lists:foldl(fun(L,N) ->
						[_,_,Sum,_,_] = L,
						if
							(Sum rem 2) == 1 ->
								N+1;
							true ->
								N
						end
				end,0, lists:sublist(Data, Mod)),
	sum_info(tl(Data),Mod,[S|R]).


shake_info(Mod) ->
	{ok,Data} = gen_server:call(ssqiu_server, {get_tongji,all}),
	shake_info(Data,Mod,{[],[]}).

shake_info(Data,Mod,{R1,R2}) when length(Data) < Mod->
	[{lists:min(R1),lists:max(R1)},{lists:min(R2),lists:max(R2)}];
shake_info([[_,_,Int,_,_]|T]=Data,Mod,{R1,R2}) ->
	I = if
		
			Int =< 99 ->
				0;
			true ->
				1
		end,
	II = if
			 Int rem 2 == 1 ->
				 1;
			 true ->
				 0
		 end,
	{S1,_} = lists:foldl(fun([_,_,Sum,_,_],{Shake,Up}) ->
						if
							Sum =< 99,Up == 1 ->
								{Shake+1,0};
							Sum > 99,Up == 0 ->
								{Shake+1,1};
							Sum =< 99 ->
								{Shake,0};
							true ->
								{Shake,1}
						end
				end, {0,I}, lists:sublist(T, Mod-1)),
	
	{S2,_} = lists:foldl(fun([_,_,Sum,_,_],{Shake,Up}) ->
						if
							Sum rem 2 == 1,Up == 0 ->
								{Shake+1,1};
							Sum rem 2 == 0,Up == 1 ->
								{Shake+1,0};
							Sum rem 2 == 0 ->
								{Shake,0};
							true ->
								{Shake,1}
			
						end
				end, {0,II}, lists:sublist(T, Mod-1)),	
	
	shake_info(T,Mod,{[S1|R1],[S2|R2]}).

link_info(Num) ->
	{ok,Data} = gen_server:call(ssqiu_server, {get_tongji,all}),
	link_info(Data,Num,[]).
link_info(Data,Num,RR) when length(Data) < 31->
	{lists:min(RR),lists:max(RR)};
link_info(Data,Num,RR) ->
	R = lists:foldl(fun([_,N,_,_,_],AccIn) ->
						if
							N == Num ->
								AccIn+1;						
							true ->
								AccIn
						end
				end, 0, lists:sublist(Data, 31)),
	link_info(tl(Data),Num,[R|RR]).

xielink_ifno(Mod) ->
	{ok,History} = gen_server:call(ssqiu_server, {get_history,all}),
	xielink_ifno(History,Mod,[]).	

xielink_ifno(History,Mod,RR) when length(History) =< Mod ->
	{lists:min(RR),lists:max(RR)};
xielink_ifno(History,Mod,RR) ->
	{R,_} = lists:foldl(fun({_,IntL},{Acc,Index}) ->
					{_,H2} = lists:nth(Index + 1, History),
					N =lists:foldl(fun(X,AccIn) ->
										IS_HIG = lists:member(ssqiu_server:plus_one(X), H2),
										IS_LOW = lists:member(ssqiu_server:minu_one(X), H2),
										if
											IS_HIG , IS_LOW ->
												AccIn +2;
											IS_HIG orelse IS_LOW ->
												AccIn + 1;
											true ->
												AccIn
										end	
								end, Acc, IntL),
					{N,Index+1}
					end, {0,1}, lists:sublist(History, Mod)),

	xielink_ifno(tl(History),Mod,[R|RR]).

	
	