-module(ack_crash).
-behaviour(gen_server).

-export([start_link/3, init/1, handle_call/3, terminate/2]).
-export([start_default/1]).

start_default(SendsTweets) -> ack_crash:start_link(SendsTweets, "Good Morning", ["Good Day", "Good Night"]).

start_link(SendsTweets, Phrase, Responses) -> gen_server:start_link(?MODULE, [SendsTweets, Phrase, Responses], []).

init([SendsTweets, Phrase, Responses]) -> {ok, [SendsTweets, Phrase, Responses]}.


handle_call({tweet, Twitterer}, From, [SendsTweets, Phrase, []]) ->
  {stop, normal, "No more responses", [SendsTweets, Phrase, []]};

handle_call({tweet, Twitterer}, From, [SendsTweets, Phrase, Responses]) ->
  [Response|Rest] = Responses,
  SendsTweets ! {tweet, Response},
  io:format("Received tweet from ~p\nResponses left: ~p", [Twitterer, Rest]),
  {reply, Response, [SendsTweets, Phrase, Rest]}.

terminate(Reason, State) ->
  io:format("Terminating: ~p", [Reason]).


