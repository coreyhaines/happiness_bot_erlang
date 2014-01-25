-module(ack_crash).

-compile(export_all).

initialize(SendsTweets, Phrase, Responses) ->
  spawn(?MODULE, spread_joy, [SendsTweets, Phrase, Responses]).


% process listening to twitter search (for phrase)
% |
% spread_joy (when a match comes in)
% figure out response to send
% |
% process that sends a tweet response back to original twitterer
%

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

