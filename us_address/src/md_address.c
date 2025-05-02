/*
 * Call Melissa Data Address Object to verify the address
 */

#include <string.h>
#include <stdio.h>
#include "nif_utils.h"
#include "mdAddr.h"

ErlNifResourceType *md_resource_type;
typedef struct
{
  mdAddr addr;
} AddressPtr;

/*
 * Sets the Address Object based on the key and value supplied
 */
static ERL_NIF_TERM handle_pair(ErlNifEnv *env, const ERL_NIF_TERM key, const ERL_NIF_TERM value, mdAddr address)
{
  ERL_NIF_TERM result = enif_make_int(env, 0);

  // Any value that is not a string is ignored.
  if (!enif_is_binary(env, value))
    return result;

  char *skey = dup_elixir_string(env, key);
  char *svalue = dup_elixir_string(env, value);

  if (skey == 0 || svalue == 0)
    return result;

  if (strcmp(skey, "company") == 0)
  {
    mdAddrSetCompany(address, svalue);
  }
  else if (strcmp(skey, "last_name") == 0)
  {
    mdAddrSetLastName(address, svalue);
  }
  else if (strcmp(skey, "address") == 0)
  {
    mdAddrSetAddress(address, svalue);
  }
  else if (strcmp(skey, "address2") == 0)
  {
    mdAddrSetAddress2(address, svalue);
  }
  else if (strcmp(skey, "last_line") == 0)
  {
    mdAddrSetLastLine(address, svalue);
  }
  else if (strcmp(skey, "suite") == 0)
  {
    mdAddrSetSuite(address, svalue);
  }
  else if (strcmp(skey, "city") == 0)
  {
    mdAddrSetCity(address, svalue);
  }
  else if (strcmp(skey, "state") == 0)
  {
    mdAddrSetState(address, svalue);
  }
  else if (strcmp(skey, "zip") == 0)
  {
    mdAddrSetZip(address, svalue);
  }
  else if (strcmp(skey, "plus4") == 0)
  {
    mdAddrSetPlus4(address, svalue);
  }
  else if (strcmp(skey, "urbanization") == 0)
  {
    mdAddrSetUrbanization(address, svalue);
  }
  else
  {
    printf("Unknown key: %s => %s\n\n", skey, svalue);
    result = enif_make_badarg(env);
  }

  free(skey);
  free(svalue);
  return result;
}

static ERL_NIF_TERM parse_request(ErlNifEnv *env, const ERL_NIF_TERM term, mdAddr address)
{
  ERL_NIF_TERM key, value;
  ErlNifMapIterator iter;
  size_t size = 0;

  if (!enif_map_iterator_create(env, term, &iter, ERL_NIF_MAP_ITERATOR_FIRST))
    return enif_make_badarg(env);

  while (enif_map_iterator_get_pair(env, &iter, &key, &value))
  {
    size += 1;
    handle_pair(env, key, value, address);

    enif_map_iterator_next(env, &iter);
  }
  enif_map_iterator_destroy(env, &iter);

  return enif_make_int(env, size);
}

/*
 * The delivery point is made up from "#{zip}#{plus4}#{delivery_point_code}
 */
static ERL_NIF_TERM get_delivery_point(ErlNifEnv *env, mdAddr address)
{
  char str_delivery_point[512];

  strcpy((char *)&str_delivery_point, mdAddrGetZip(address));
  strcat((char *)&str_delivery_point, mdAddrGetPlus4(address));
  strcat((char *)&str_delivery_point, mdAddrGetDeliveryPointCode(address));

  return to_elixir_string(env, str_delivery_point);
}

static ERL_NIF_TERM response_map(ErlNifEnv *env, mdAddr address)
{
  ERL_NIF_TERM map = enif_make_new_map(env);
  map_set_pair(env, "address", mdAddrGetAddress(address), &map);
  map_set_pair(env, "address2", mdAddrGetAddress2(address), &map);
  map_set_pair(env, "suite", mdAddrGetSuite(address), &map);
  map_set_pair(env, "city", mdAddrGetCity(address), &map);
  map_set_pair(env, "state", mdAddrGetState(address), &map);
  map_set_pair(env, "zip", mdAddrGetZip(address), &map);
  map_set_pair(env, "plus4", mdAddrGetPlus4(address), &map);
  map_set_pair(env, "address_key", mdAddrGetAddressKey(address), &map);
  map_set_pair(env, "melissa_address_key", mdAddrGetMelissaAddressKey(address), &map);
  map_set_pair(env, "melissa_address_key_base", mdAddrGetMelissaAddressKeyBase(address), &map);
  map_set_pair_term(env, "delivery_point", get_delivery_point(env, address), &map);
  map_set_pair(env, "time_zone_code", mdAddrGetTimeZoneCode(address), &map);
  map_set_pair(env, "time_zone", mdAddrGetTimeZone(address), &map);
  map_set_pair(env, "address_type", mdAddrGetAddressTypeString(address), &map);
  map_set_pair(env, "address_type_code", mdAddrGetAddressTypeCode(address), &map);

  // Parsed Address Elements
  map_set_pair(env, "suite_name", mdAddrGetParsedSuiteName(address), &map);
  map_set_pair(env, "suite_range", mdAddrGetParsedSuiteRange(address), &map);
  map_set_pair(env, "address_range", mdAddrGetParsedAddressRange(address), &map);
  map_set_pair(env, "pre_direction", mdAddrGetParsedPreDirection(address), &map);
  map_set_pair(env, "post_direction", mdAddrGetParsedPostDirection(address), &map);
  map_set_pair(env, "street_name", mdAddrGetParsedStreetName(address), &map);
  map_set_pair(env, "suffix", mdAddrGetParsedSuffix(address), &map);
  map_set_pair(env, "private_mailbox_name", mdAddrGetParsedPrivateMailboxName(address), &map);
  map_set_pair(env, "private_mailbox_number", mdAddrGetParsedPrivateMailboxNumber(address), &map);
  map_set_pair(env, "garbage", mdAddrGetParsedGarbage(address), &map);

  // Return codes
  map_set_pair(env, "result_codes", mdAddrGetResults(address), &map);
  return map;
}

static ERL_NIF_TERM nif_address_version(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  AddressPtr *obj;
  if (!enif_get_resource(env, argv[0], md_resource_type, (void *)&obj))
    return enif_make_badarg(env);

  mdAddr address = obj->addr;
  ERL_NIF_TERM map = enif_make_new_map(env);

  map_set_pair(env, "build_number", mdAddrGetBuildNumber(address), &map);
  map_set_pair(env, "initialize_status", mdAddrGetInitializeErrorString(address), &map);
  map_set_pair(env, "database_date", mdAddrGetDatabaseDate(address), &map);
  map_set_pair(env, "expiration_date", mdAddrGetExpirationDate(address), &map);
  map_set_pair(env, "license_expiration_date", mdAddrGetLicenseExpirationDate(address), &map);
  return map;
}

static ERL_NIF_TERM nif_address_create(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  AddressPtr *obj = enif_alloc_resource(md_resource_type, sizeof(AddressPtr));
  obj->addr = mdAddrCreate();

  char *data_path = dup_elixir_string(env, argv[0]);
  mdAddrSetPathToUSFiles(obj->addr, data_path);
  // Required to use mdAddrGetMelissaAddressKey()
  // mdAddrSetPathToAddrKeyDataFiles(obj->addr, data_path);
  free(data_path);

  ERL_NIF_TERM status, result;
  int ec = mdAddrInitializeDataFiles(obj->addr);
  if (ec == 0)
  {
    status = enif_make_atom(env, "ok");
    result = enif_make_resource(env, obj);
  }
  else
  {
    status = enif_make_atom(env, "error");
    const char *error_string = mdAddrGetInitializeErrorString(obj->addr);
    result = to_elixir_string(env, error_string);
  }
  // TODO: Does this call mdAddrDestroy on :error above
  enif_release_resource(obj);

  return enif_make_tuple2(env, status, result);
}

// Cleanup address instance when BEAM GC cleans up memory
void nif_destroy_address(ErlNifEnv *env, void *res)
{
  //  printf("nif_destructor_address: %p\n", ((AddressPtr*)res)->addr);
  mdAddrDestroy(((AddressPtr *)res)->addr);
}

static ERL_NIF_TERM nif_address_verify(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  if (argc != 2)
    return enif_make_badarg(env);

  AddressPtr *obj;
  if (!enif_get_resource(env, argv[0], md_resource_type, (void *)&obj))
    return enif_make_badarg(env);

  mdAddrClearProperties(obj->addr);

  //  printf("nif_init_address: %p\n", obj->addr);

  ERL_NIF_TERM result = parse_request(env, argv[1], obj->addr);
  int rc = mdAddrVerifyAddress(obj->addr);

  result = response_map(env, obj->addr);
  return result;
}

int nif_on_load(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM load_info)
{
  md_resource_type = enif_open_resource_type(
      env,
      NULL,
      "md_address",
      nif_destroy_address,
      ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER,
      NULL);
  return 0;
}

static ErlNifFunc nif_funcs[] = {
    // Dirty scheduler options: ERL_NIF_DIRTY_JOB_CPU_BOUND or ERL_NIF_DIRTY_JOB_IO_BOUND
    {"init", 1, nif_address_create, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"verify_c", 2, nif_address_verify},
    {"version", 1, nif_address_version},
};

ERL_NIF_INIT(Elixir.USAddress.Nif, nif_funcs, nif_on_load, NULL, NULL, NULL)
