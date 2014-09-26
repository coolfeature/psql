-module(estore_interface).

-callback init(Adapter :: atom()) -> 
  'ok'|tuple('error', Reason :: string()).

-callback models(Adapter :: atom()) -> 
  Records :: list() | tuple('error', Reason :: string()).
 
-callback new(Adapter :: atom(),Record :: record()) -> 
  'ok'|tuple('error', Reason :: string()).
 
-callback save(Adapter :: atom(),Record :: record()) -> 
  'ok'|tuple('error', Reason :: string()).

-callback delete(Adapter :: atom(),Record :: record(),Conditions :: list()) -> 
  'ok'|tuple('error', Reason :: string()).

-callback find(Adapter :: atom(),Name :: atom(),Conditions :: list()) -> 
  Records :: list() | tuple('error', Reason :: string()).

