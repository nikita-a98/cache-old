%%%-------------------------------------------------------------------
%%% @author nikita
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. Янв. 2019 14:54
%%%-------------------------------------------------------------------
-module(cache).
-author("nikita").

-record(record, {
  key :: term(),
  value :: term()
}).

%% API
-export([
  setup/0,
  set/2,
  set/3,
  get/1
]).

-export([
  delete/1
]).
%%====================================================================
%% API functions
%%====================================================================

%% Создание схемы, запуск mnesia, создание таблицы с именем record и полями key, value
setup() ->
  mnesia:create_schema([node()]),
  mnesia:start(),
  mnesia:create_table(record,
    [{disc_copies, [node()]},
     {attributes, record_info(fields, record)}]),
  ok.

%% Функция добавления записи с временем жизни 60 секунд в таблицу
set(Key, Val) ->
  Insert =
    fun() ->
      mnesia:write(
        #record{
          key = Key,
          value = Val
        })
    end,
  {atomic, Results} = mnesia:transaction(Insert),
  timer:apply_interval(60*1000, ?MODULE, delete, [Key]),
  Results.

%% Функция добавления записи с бесконечным/определенным временем жизни в таблицу
set(Key, Val, [ttl, Time]) ->
  Insert =
    fun() ->
      mnesia:write(
        #record{
          key = Key,
          value = Val
        })
    end,
  {atomic, Results} = mnesia:transaction(Insert),
  if
    (Time == infinity) or (Time == 0) ->
      Results;
    Time > 0 ->
      timer:apply_interval(Time*1000, ?MODULE, delete, [Key]),
      Results
  end.

%% Функция поиска по ключу записи в таблице
get(Key) ->
  F =
    fun() ->
      mnesia:match_object({record, Key, '_'})
    end,
  {atomic, Results} = mnesia:transaction(F),
  Results.

%%====================================================================
%% Internal function
%%====================================================================

%% Функция удаления записи с таблицы
delete(Key) ->
  F =
    fun() ->
      mnesia:delete({record, Key})
    end,
  {atomic, Results} = mnesia:transaction(F),
  Results.