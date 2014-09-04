-module(estore_test).

-export([
  new/0
  ,new/1
  ,new/2
  ,test/0
  ,print/2
]).


-define(SCHEMA,lamazone).
-define(TABLE,shopper).
-define(TABLE2,test_table2).
-define(DB,test_db).
-define(FIELD,field).
-define(FIELD2,field2).
-define(FIELDS,[{'F',field},{'F2',field2},?FIELD]).
-define(INDEX,sample_index).
-define(WHERE,[{{t,oid},'=',{ix,indexrelid}},'AND',{{i,oid},'=',{ix,indexrelid}}]).
-define(GROUPBY,?FIELDS).
-define(JOIN,[{{'LEFT OUTER JOIN',{?SCHEMA,?TABLE2,'T2'}},'ON',{{'T',?TABLE},'=',{'T2',?TABLE2}}}]).

-include("pgsql.hrl").

%% -----------------------------------------------------------------------------

new() ->
  new(shopper).
new(Model) ->
  new(estore_pgsql,Model).
new(Module,Model) when Model =:= 'shopper' ->
  PhoneTypeRecord = estore:new(Module,'phone_type'),
  MobilePhoneType = PhoneTypeRecord#'phone_type'{'type' = "Mobile"},
  HomePhoneType = PhoneTypeRecord#'phone_type'{'type' = "Home"},
  PhoneRecord = estore:new(Module,'phone'),

  AddressTypeRecord = estore:new(Module,'address_type'),
  AddressRecord = estore:new(Module,'address'),

  Phone1 = PhoneRecord#'phone'{'number' = "07871259234", 'type' = MobilePhoneType},
  Phone2 = PhoneRecord#'phone'{'number' = "01413872123", 'type' = HomePhoneType},

  Address1 = AddressRecord#'address'{
    'line1' = "Flat 1/2"
    ,'line2' = "56 Cecil St"
    ,'line3' = null
    ,'postcode' = "G128RJ"
    ,'city' = "Glasgow"
    ,'country' = "Scotland"
    ,'type' =  AddressTypeRecord#'address_type'{'type' = "Residential"}
  },
  Address2 = AddressRecord#'address'{
    'line1' = "Flat 2/3"
    ,'line2' = "7 Ravel Row"
    ,'line3' = null
    ,'postcode' = "G315EW"
    ,'city' = "Glasgow"
    ,'country' = "Scotland"
    ,'type' =  AddressTypeRecord#'address_type'{'type' = "Shipping"}
  },

  Record = estore:new(Module,Model),
  Record#'shopper'{
    'fname' = "Szymon"
    ,'mname' = "Piotr"
    ,'lname' = "Czaja"
    ,'dob' = "1987-03-01"
    ,'phone' = [Phone1,Phone2]
    ,'address' = [Address1,Address2]
  };
new(Module,Model) when Model =:= 'user' ->
  estore:new(Module,Model).

test() ->
  print('create_schema/1',pgsql:create_schema(?SCHEMA)),
  print('create_schema/2',pgsql:create_schema(?SCHEMA,['ifnotexists'])),
  print('create_index/3',pgsql:create_index(someindex,sometab,[col1,col2])),
  print('create_index/4',pgsql:create_index(someindex,{schema,sometab},[col1,col2],[nolock])),
  print('drop_table/1',pgsql:drop_table(?TABLE)),
  print('drop_table/2',pgsql:drop_table(?SCHEMA,?TABLE)),
  print('drop_table/3',pgsql:drop_table(?SCHEMA,?TABLE,[ifexists,cascade])),

  print('select/1 {S,T,A}',pgsql:select({?SCHEMA,?TABLE,'T'})),
  print('select/1 {S,T}',pgsql:select({?SCHEMA,?TABLE})),
  print('select/1 T',pgsql:select(?TABLE)),
  print('select/1 [{S,T,A},{S,T,A}]',pgsql:select([{?SCHEMA,?TABLE,'T'},{?SCHEMA,?TABLE2,'T2'}])),
  print('select/2 {S,T,A}, field',pgsql:select({?SCHEMA,?TABLE,'T'},field)),
  print('select/2 {S,T}, field',pgsql:select({?SCHEMA,?TABLE},field)),
  print('select/2 T, field',pgsql:select({?SCHEMA,?TABLE},field)),
  print('select/2 [{S,T,A},{S,T,A}], field',pgsql:select([{?SCHEMA,?TABLE,'T'},{?SCHEMA,?TABLE2,'T2'}],field)),
  print('select/3 {S,T,A},field,W',pgsql:select({?SCHEMA,?TABLE,'T'},field,?WHERE)),
  print('select/3 {S,T},field,W',pgsql:select({?SCHEMA,?TABLE},field,?WHERE)),
  print('select/3 T,field,W',pgsql:select(?TABLE,field,?WHERE)),
  print('select/3 [{S,T,A},{S,T,A}],[fields],W',pgsql:select([{?SCHEMA,?TABLE,'T'},{?SCHEMA,?TABLE2,'T2'}],?FIELDS,?WHERE)),
  print('select/4 {S,T,A},field,W,G',pgsql:select({?SCHEMA,?TABLE,'T'},field,?WHERE,?GROUPBY)),
  print('select/4 {S,T},field,W,G',pgsql:select({?SCHEMA,?TABLE},field,?WHERE,?GROUPBY)),
  print('select/4 T,field,W,G',pgsql:select(?TABLE,field,?WHERE,?GROUPBY)),
  print('select/4 [{S,T,A},{S,T,A}],field,W,G',pgsql:select([{?SCHEMA,?TABLE,'T'},{?SCHEMA,?TABLE2,'T2'}],field,?WHERE,?GROUPBY)),
  print('select/5 {S,T,A},field,J,W,G',pgsql:select({?SCHEMA,?TABLE,'T'},field,?JOIN,?WHERE,?GROUPBY)),
  print('select/5 {S,T},field,J,W,G',pgsql:select({?SCHEMA,?TABLE},field,?JOIN,?WHERE,?GROUPBY)),
  print('select/5 T,field,J,W,G',pgsql:select(?TABLE,field,?JOIN,?WHERE,?GROUPBY)),
  print('select/5 [{S,T,A},{S,T,A}],field,J,W,G',pgsql:select([{?SCHEMA,?TABLE,'T'},{?SCHEMA,?TABLE2,'T2'}],field,?JOIN,?WHERE,?GROUPBY)),

  print('create_table/2 table,[field]',pgsql:create_table(?TABLE,[?FIELD])),
  print('create_table/3 schema,table,[field]',pgsql:create_table(?SCHEMA,?TABLE,[?FIELD])),
  print('select_index/1 index',pgsql:select_index(?INDEX)),
  print('select_index/2 schema,index',pgsql:select_index(?SCHEMA,?INDEX)),
  print('table_info/3 db,schema,tb',pgsql:table_info(?DB,?SCHEMA,?TABLE)).

print(T,R) ->
  io:fwrite("~n~n" ++ atom_to_list(T) ++ "~n~s",[R]).

