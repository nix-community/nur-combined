#include "plugin.h"
#include "labkoka.h"

#include <stdbool.h>
#include <stdint.h>
#include <string.h>

void payload_text(hanga_engine_host_value_t *ret, const char *value);
void payload_flag(hanga_engine_host_value_t *ret, bool value);
void payload_empty(hanga_engine_host_value_t *ret);
void payload_gravity(hanga_engine_host_value_t *ret);
void payload_fracture(hanga_engine_host_value_t *ret);
void payload_methods(hanga_engine_host_value_t *ret, const char **topics, size_t n);
void payload_catalog(plugin_list_string_t *ret, const char **parts, size_t n);
int64_t bag_int(const hanga_engine_host_value_t *payload, const char *key);
int bag_text_eq(const hanga_engine_host_value_t *payload, const char *key, const char *want);
int bus_has(const hanga_engine_host_value_t *payload, const char **topics, size_t n);
void host_log_info(const char *message);
void greet_peers(void);

static const char *catalog_parts[] = {"air", "koka", "effect"};
static const char *bus_topics[] = {
    "ping", "name", "catalog", "gravity", "has", "methods", "voxel", "fracture-kit", "loot-item",
};

static kk_context_t *boot(void) {
  static kk_context_t *ctx;
  if (ctx == NULL) {
    ctx = kk_main_start(0, NULL);
    kk_labkoka__init(ctx);
  }
  return ctx;
}

void kk_hanga_payload_text(intptr_t ret, kk_string_t s, kk_context_t *ctx) {
  payload_text((hanga_engine_host_value_t *)ret, kk_string_cbuf_borrow(s, NULL, ctx));
}

void kk_hanga_payload_flag(intptr_t ret, bool value, kk_context_t *ctx) {
  (void)ctx;
  payload_flag((hanga_engine_host_value_t *)ret, value);
}

void kk_hanga_payload_empty(intptr_t ret, kk_context_t *ctx) {
  (void)ctx;
  payload_empty((hanga_engine_host_value_t *)ret);
}

void kk_hanga_payload_gravity(intptr_t ret, kk_context_t *ctx) {
  (void)ctx;
  payload_gravity((hanga_engine_host_value_t *)ret);
}

void kk_hanga_payload_fracture(intptr_t ret, kk_context_t *ctx) {
  (void)ctx;
  payload_fracture((hanga_engine_host_value_t *)ret);
}

void kk_hanga_payload_methods(intptr_t ret, kk_context_t *ctx) {
  (void)ctx;
  payload_methods((hanga_engine_host_value_t *)ret, bus_topics,
                  sizeof(bus_topics) / sizeof(bus_topics[0]));
}

int32_t kk_hanga_bag_int32(intptr_t payload, kk_string_t key, kk_context_t *ctx) {
  return (int32_t)bag_int((const hanga_engine_host_value_t *)payload,
                          kk_string_cbuf_borrow(key, NULL, ctx));
}

bool kk_hanga_bag_text_eq(intptr_t payload, kk_string_t key, kk_string_t want, kk_context_t *ctx) {
  return bag_text_eq((const hanga_engine_host_value_t *)payload,
                     kk_string_cbuf_borrow(key, NULL, ctx),
                     kk_string_cbuf_borrow(want, NULL, ctx)) != 0;
}

bool kk_hanga_bus_has(intptr_t payload, kk_context_t *ctx) {
  (void)ctx;
  return bus_has((const hanga_engine_host_value_t *)payload, bus_topics,
                 sizeof(bus_topics) / sizeof(bus_topics[0])) != 0;
}

__attribute__((export_name("exports_hanga_engine_guest_abi"))) int32_t
exports_hanga_engine_guest_abi(void) {
  return 6;
}

__attribute__((export_name("exports_hanga_engine_guest_ready"))) void
exports_hanga_engine_guest_ready(void) {
  boot();
  host_log_info("lab_koka ready");
  greet_peers();
}

__attribute__((export_name("exports_hanga_engine_guest_voxel_catalog"))) void
exports_hanga_engine_guest_voxel_catalog(plugin_list_string_t *ret) {
  boot();
  payload_catalog(ret, catalog_parts, sizeof(catalog_parts) / sizeof(catalog_parts[0]));
}

__attribute__((export_name("exports_hanga_engine_guest_query_voxel"))) int32_t
exports_hanga_engine_guest_query_voxel(int32_t x, int32_t y, int32_t z) {
  return kk_labkoka_query_voxel(x, y, z, boot());
}

__attribute__((export_name("exports_hanga_engine_guest_invoke"))) void
exports_hanga_engine_guest_invoke(plugin_string_t *caller, plugin_string_t *topic,
                                  hanga_engine_host_value_t *payload,
                                  hanga_engine_host_value_t *ret) {
  (void)caller;
  kk_context_t *ctx = boot();
  const char *ptr = topic && topic->ptr ? (const char *)topic->ptr : "";
  size_t len = topic ? topic->len : 0;
  kk_string_t name = kk_string_alloc_from_qutf8n((kk_ssize_t)len, ptr, ctx);
  kk_labkoka_invoke(name, (intptr_t)payload, (intptr_t)ret, ctx);
}
