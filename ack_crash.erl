-module(ack_crash).
-behaviour(gen_server).

-export([start_link/3, init/1, handle_call/3, terminate/2]).

start_link(SendsTweets, Phrase, Responses) -> gen_server:start_link(?MODULE, [SendsTweets, Phrase, Responses], []).

init([SendsTweets, Phrase, Responses]) -> {ok, [SendsTweets, Phrase, Responses]}.


handle_call({tweet, Twitterer}, From, [SendsTweets, Phrase, []]) ->
  {stop, normal, "No more responses", [SendsTweets, Phrase, []]};

handle_call({tweet, Twitterer}, From, [SendsTweets, Phrase, Responses]) ->
  [Response|Rest] = Responses,
  SendsTweets ! {tweet, Response},
  {reply, Response, [Phrase, Rest]}.

terminate(Reason, State) ->
  io:format("Terminating: ~p", [Reason]).

spread_joy(_, _, []) ->
  receive
    {tweet, _} ->
      {stop, no_more_responses};
    _ ->
      {stop, unknown_message}
  end;

spread_joy(SendsTweets, Phrase, Responses) ->
  receive
    {tweet, Twitterer} ->
      [Response|Rest] = Responses,
      SendsTweets ! {tweet, Twitterer, Response},
      spread_joy(SendsTweets, Phrase, Rest);
    {stop} ->
      {stop, received_stop};
    _ ->
      {stop, unknown_message}
  end.

