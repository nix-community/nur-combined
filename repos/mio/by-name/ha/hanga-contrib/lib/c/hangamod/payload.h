#ifndef HANGAMOD_PAYLOAD_H
#define HANGAMOD_PAYLOAD_H

#include "plugin.h"

#include <stdbool.h>
#include <stdint.h>
#include <string.h>

/* Returned WIT lists/strings must be heap copies (`plugin_string_dup`).
   `cabi_post_*` frees them after the host lifts the result. Imports (`log`,
   `send`) only borrow: free values you allocated, never free string literals. */

void payload_text(hanga_engine_host_value_t *ret, const char *value);
void payload_text_n(hanga_engine_host_value_t *ret, const char *value, size_t len);
void payload_flag(hanga_engine_host_value_t *ret, bool value);
void payload_empty(hanga_engine_host_value_t *ret);
void payload_fail(hanga_engine_host_value_t *ret, const char *reason);
void payload_gravity(hanga_engine_host_value_t *ret);
void payload_fracture(hanga_engine_host_value_t *ret);
void payload_methods(hanga_engine_host_value_t *ret, const char *const *topics, size_t n);
void payload_catalog(plugin_list_string_t *ret, const char *const *parts, size_t n);
int64_t bag_int(const hanga_engine_host_value_t *payload, const char *key);
int bag_text_eq(const hanga_engine_host_value_t *payload, const char *key, const char *want);
int bus_has(const hanga_engine_host_value_t *payload, const char *const *topics, size_t n);
void host_log_info(const char *message);
void greet_peers(void);
int topic_eq(const plugin_string_t *topic, const char *want);

#endif
