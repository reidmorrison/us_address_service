#include "erl_nif.h"

/*
 * Helper methods for working with Elixir and NIF
 */

/*
 * Returns a new pointer to a string holding a copy of the supplied Elixir String.
 *
 * NOTES:
 * - Remember to free the returned string when non-zero to prevent memory leaks
 */
extern char* dup_elixir_string(ErlNifEnv *env, const ERL_NIF_TERM elixir_string);

/*
 * Returns an Elixir String from a null terminated string.
 */
extern ERL_NIF_TERM to_elixir_string(ErlNifEnv *env, const char* string);

/*
 * Set an atom and string value pair into a map.
 */
extern ERL_NIF_TERM map_set_pair(ErlNifEnv *env, const char* skey, const char* svalue, ERL_NIF_TERM* map);

/*
 * Set an atom and elixir value pair into a map.
 */
extern ERL_NIF_TERM map_set_pair_term(ErlNifEnv *env, const char* skey, ERL_NIF_TERM value, ERL_NIF_TERM* map);

