%% Author: wave
%% Created: 2012-10-24
%% Description: TODO: Add description to ssqiu_show_SUITE
-module(ssqiu_show_SUITE).


-define(TEST_PATH,"/home/wave/workspace/ssqiu").
-compile(export_all).

all() ->[
		test_call_tongji
		].

suite() ->
	[].

init_per_suite(Config) ->
	
	Config.

end_per_suite(_Config) ->
	
	ok.


test_show(_) ->
	ssqiu_server:start_link(?TEST_PATH),
	ssqiu_show:show(3, 5),
	timer:sleep(2000),
	ok.

test_tongji(_) ->
	ssqiu_server:start_link(?TEST_PATH),
	R = ssqiu_show:tongji(4, 11),
	error_logger:info_msg("<<<:~p~n", [R]),
	ok.	

test_repeat(_) ->
	ssqiu_server:start_link(?TEST_PATH),
	R = ssqiu_show:xielink_ifno(31),
	error_logger:info_msg("<<<:~p~n", [R]),
	ok.	

test_my(_) ->
	ssqiu_server:start_link(?TEST_PATH),
	{ok,Data} = gen_server:call(ssqiu_server, {get_tongji,100}),
	R = lists:foldl(fun([_,N,_,_,_],{N0,N2,N3,N4,N5}) ->
						case N of
							0 ->
								{N0+1,N2,N3,N4,N5};
							2 ->
								{N0,N2+1,N3,N4,N5};
							3 ->
								{N0,N2,N3+1,N4,N5};
							4 ->
								{N0,N2,N3,N4+1,N5};
							5 ->
								{N0,N2,N3,N4,N5+1}
						end
				end, {0,0,0,0,0}, Data),
	error_logger:info_msg("<<<:~p~n", [R]),
	%% {26,50,4,17,3}
	ok.


test_init_raw_file(_) ->
	ssq:init_raw_file(?TEST_PATH),
	true = filelib:is_file(?TEST_PATH ++ "/.ssq_raw"),
	ok.

