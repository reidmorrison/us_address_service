#include <string.h>
#include "nif_utils.h"

extern char* dup_elixir_string(ErlNifEnv *env, const ERL_NIF_TERM elixir_string) {
  ErlNifBinary bin;
  if(!enif_inspect_iolist_as_binary(env, elixir_string, &bin)) {
    enif_make_badarg(env);
    enif_release_binary(&bin);
    return 0;
  }
  char *string = strndup((char*) bin.data, bin.size);
  enif_release_binary(&bin);
  return string;
}

extern ERL_NIF_TERM to_elixir_string(ErlNifEnv *env, const char* string) {
  ERL_NIF_TERM elixir_string;

  unsigned char *bin = enif_make_new_binary(env, strlen(string), &elixir_string);
  strncpy((char*)bin, string, strlen(string));

  return elixir_string;
}

extern ERL_NIF_TERM map_set_pair_term(ErlNifEnv *env, const char* skey, ERL_NIF_TERM value, ERL_NIF_TERM* map) {
  ERL_NIF_TERM key   = enif_make_atom(env, skey);
  return enif_make_map_put(env, *map, key, value, map);
}

extern ERL_NIF_TERM map_set_pair(ErlNifEnv *env, const char* skey, const char* svalue, ERL_NIF_TERM* map) {
  ERL_NIF_TERM value = to_elixir_string(env, svalue);
  return map_set_pair_term(env, skey, value, map);
}
