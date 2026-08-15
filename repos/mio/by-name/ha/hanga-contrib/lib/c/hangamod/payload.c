#include "payload.h"

#include <stdlib.h>

__attribute__((export_name("cabi_realloc"))) void *cabi_realloc(void *ptr, size_t old_size,
                                                                size_t align, size_t new_size) {
  (void)old_size;
  (void)align;
  if (new_size == 0) {
    free(ptr);
    return NULL;
  }
  void *out = realloc(ptr, new_size);
  return out;
}

static void own_str(plugin_string_t *ret, const char *value) {
  plugin_string_dup(ret, value);
}

static hanga_engine_host_cell_t *alloc_cells(size_t n) {
  return (hanga_engine_host_cell_t *)cabi_realloc(
      NULL, 0, _Alignof(hanga_engine_host_cell_t), n * sizeof(hanga_engine_host_cell_t));
}

static hanga_engine_host_field_t *alloc_fields(size_t n) {
  return (hanga_engine_host_field_t *)cabi_realloc(
      NULL, 0, _Alignof(hanga_engine_host_field_t), n * sizeof(hanga_engine_host_field_t));
}

void payload_text(hanga_engine_host_value_t *ret, const char *value) {
  hanga_engine_host_cell_t *cells = alloc_cells(1);
  cells[0].tag = HANGA_ENGINE_HOST_CELL_TEXT;
  own_str(&cells[0].val.text, value);
  ret->cells.ptr = cells;
  ret->cells.len = 1;
  ret->root = 0;
}

void payload_text_n(hanga_engine_host_value_t *ret, const char *value, size_t len) {
  hanga_engine_host_cell_t *cells = alloc_cells(1);
  cells[0].tag = HANGA_ENGINE_HOST_CELL_TEXT;
  plugin_string_dup_n(&cells[0].val.text, value, len);
  ret->cells.ptr = cells;
  ret->cells.len = 1;
  ret->root = 0;
}

void payload_flag(hanga_engine_host_value_t *ret, bool value) {
  hanga_engine_host_cell_t *cells = alloc_cells(1);
  cells[0].tag = HANGA_ENGINE_HOST_CELL_FLAG;
  cells[0].val.flag = value;
  ret->cells.ptr = cells;
  ret->cells.len = 1;
  ret->root = 0;
}

void payload_empty(hanga_engine_host_value_t *ret) {
  hanga_engine_host_cell_t *cells = alloc_cells(1);
  cells[0].tag = HANGA_ENGINE_HOST_CELL_EMPTY;
  ret->cells.ptr = cells;
  ret->cells.len = 1;
  ret->root = 0;
}

void payload_fail(hanga_engine_host_value_t *ret, const char *reason) {
  hanga_engine_host_cell_t *cells = alloc_cells(1);
  cells[0].tag = HANGA_ENGINE_HOST_CELL_FAIL;
  own_str(&cells[0].val.fail, reason);
  ret->cells.ptr = cells;
  ret->cells.len = 1;
  ret->root = 0;
}

void payload_gravity(hanga_engine_host_value_t *ret) {
  hanga_engine_host_cell_t *cells = alloc_cells(5);
  hanga_engine_host_field_t *fields = alloc_fields(4);
  cells[0].tag = HANGA_ENGINE_HOST_CELL_TEXT;
  own_str(&cells[0].val.text, "down");
  cells[1].tag = HANGA_ENGINE_HOST_CELL_FLOAT;
  cells[1].val.float_ = 9.81;
  cells[2].tag = HANGA_ENGINE_HOST_CELL_FLOAT;
  cells[2].val.float_ = 5;
  cells[3].tag = HANGA_ENGINE_HOST_CELL_FLOAT;
  cells[3].val.float_ = 10;
  own_str(&fields[0].key, "kind");
  fields[0].at = 0;
  own_str(&fields[1].key, "g");
  fields[1].at = 1;
  own_str(&fields[2].key, "jump");
  fields[2].at = 2;
  own_str(&fields[3].key, "walk");
  fields[3].at = 3;
  cells[4].tag = HANGA_ENGINE_HOST_CELL_DICT;
  cells[4].val.dict.ptr = fields;
  cells[4].val.dict.len = 4;
  ret->cells.ptr = cells;
  ret->cells.len = 5;
  ret->root = 4;
}

void payload_fracture(hanga_engine_host_value_t *ret) {
  hanga_engine_host_cell_t *cells = alloc_cells(4);
  hanga_engine_host_field_t *fields = alloc_fields(3);
  cells[0].tag = HANGA_ENGINE_HOST_CELL_FLAG;
  cells[0].val.flag = true;
  cells[1].tag = HANGA_ENGINE_HOST_CELL_INT;
  cells[1].val.int_ = 1;
  cells[2].tag = HANGA_ENGINE_HOST_CELL_FLOAT;
  cells[2].val.float_ = 4;
  own_str(&fields[0].key, "can");
  fields[0].at = 0;
  own_str(&fields[1].key, "spread");
  fields[1].at = 1;
  own_str(&fields[2].key, "impulse");
  fields[2].at = 2;
  cells[3].tag = HANGA_ENGINE_HOST_CELL_DICT;
  cells[3].val.dict.ptr = fields;
  cells[3].val.dict.len = 3;
  ret->cells.ptr = cells;
  ret->cells.len = 4;
  ret->root = 3;
}

void payload_methods(hanga_engine_host_value_t *ret, const char *const *topics, size_t n) {
  hanga_engine_host_cell_t *cells = alloc_cells(n + 1);
  uint32_t *idx = (uint32_t *)cabi_realloc(NULL, 0, _Alignof(uint32_t), n * sizeof(uint32_t));
  for (size_t i = 0; i < n; i++) {
    cells[i].tag = HANGA_ENGINE_HOST_CELL_TEXT;
    own_str(&cells[i].val.text, topics[i]);
    idx[i] = (uint32_t)i;
  }
  cells[n].tag = HANGA_ENGINE_HOST_CELL_ITEMS;
  cells[n].val.items.ptr = idx;
  cells[n].val.items.len = n;
  ret->cells.ptr = cells;
  ret->cells.len = n + 1;
  ret->root = (uint32_t)n;
}

void payload_catalog(plugin_list_string_t *ret, const char *const *parts, size_t n) {
  plugin_string_t *strings =
      (plugin_string_t *)cabi_realloc(NULL, 0, _Alignof(plugin_string_t), n * sizeof(plugin_string_t));
  for (size_t i = 0; i < n; i++) {
    plugin_string_dup(&strings[i], parts[i]);
  }
  ret->ptr = strings;
  ret->len = n;
}

static int str_eq_n(const char *ptr, size_t len, const char *want) {
  size_t n = strlen(want);
  if (len != n) {
    return 0;
  }
  return memcmp(ptr, want, n) == 0;
}

static const hanga_engine_host_cell_t *root_cell(const hanga_engine_host_value_t *payload) {
  if (payload->cells.ptr == NULL || payload->root >= payload->cells.len) {
    return NULL;
  }
  return &payload->cells.ptr[payload->root];
}

static const char *field_text(const hanga_engine_host_value_t *payload, const char *key, size_t *out_len) {
  const hanga_engine_host_cell_t *cell = root_cell(payload);
  *out_len = 0;
  if (cell == NULL) {
    return "";
  }
  if (cell->tag == HANGA_ENGINE_HOST_CELL_TEXT && str_eq_n(key, strlen(key), "voxel")) {
    if (cell->val.text.ptr != NULL && cell->val.text.len > 0) {
      *out_len = cell->val.text.len;
      return (const char *)cell->val.text.ptr;
    }
    return "";
  }
  if (cell->tag != HANGA_ENGINE_HOST_CELL_DICT || cell->val.dict.ptr == NULL) {
    return "";
  }
  for (size_t i = 0; i < cell->val.dict.len; i++) {
    hanga_engine_host_field_t field = cell->val.dict.ptr[i];
    const char *fk = field.key.ptr ? (const char *)field.key.ptr : "";
    size_t fl = field.key.len;
    if (!str_eq_n(fk, fl, key) || field.at >= payload->cells.len) {
      continue;
    }
    const hanga_engine_host_cell_t *child = &payload->cells.ptr[field.at];
    if (child->tag == HANGA_ENGINE_HOST_CELL_TEXT && child->val.text.ptr != NULL) {
      *out_len = child->val.text.len;
      return (const char *)child->val.text.ptr;
    }
  }
  return "";
}

int64_t bag_int(const hanga_engine_host_value_t *payload, const char *key) {
  const hanga_engine_host_cell_t *cell = root_cell(payload);
  if (cell == NULL || cell->tag != HANGA_ENGINE_HOST_CELL_DICT || cell->val.dict.ptr == NULL) {
    return 0;
  }
  for (size_t i = 0; i < cell->val.dict.len; i++) {
    hanga_engine_host_field_t field = cell->val.dict.ptr[i];
    const char *fk = field.key.ptr ? (const char *)field.key.ptr : "";
    if (!str_eq_n(fk, field.key.len, key) || field.at >= payload->cells.len) {
      continue;
    }
    const hanga_engine_host_cell_t *child = &payload->cells.ptr[field.at];
    if (child->tag == HANGA_ENGINE_HOST_CELL_INT) {
      return child->val.int_;
    }
    if (child->tag == HANGA_ENGINE_HOST_CELL_TEXT && child->val.text.ptr != NULL && child->val.text.len > 0) {
      int64_t n = 0;
      int sign = 1;
      const char *p = (const char *)child->val.text.ptr;
      size_t len = child->val.text.len;
      size_t j = 0;
      if (len > 0 && p[0] == '-') {
        sign = -1;
        j = 1;
      }
      for (; j < len; j++) {
        if (p[j] < '0' || p[j] > '9') {
          break;
        }
        n = n * 10 + (p[j] - '0');
      }
      return n * sign;
    }
  }
  return 0;
}

int bag_text_eq(const hanga_engine_host_value_t *payload, const char *key, const char *want) {
  size_t len = 0;
  const char *text = field_text(payload, key, &len);
  return str_eq_n(text, len, want);
}

int bus_has(const hanga_engine_host_value_t *payload, const char *const *topics, size_t n) {
  const hanga_engine_host_cell_t *cell = root_cell(payload);
  const char *name = "";
  size_t len = 0;
  if (cell != NULL && cell->tag == HANGA_ENGINE_HOST_CELL_TEXT) {
    if (cell->val.text.ptr != NULL && cell->val.text.len > 0) {
      name = (const char *)cell->val.text.ptr;
      len = cell->val.text.len;
    }
  } else if (cell != NULL && cell->tag == HANGA_ENGINE_HOST_CELL_DICT) {
    name = field_text(payload, "name", &len);
    if (len == 0) {
      name = field_text(payload, "method", &len);
    }
  }
  for (size_t i = 0; i < n; i++) {
    if (str_eq_n(name, len, topics[i])) {
      return 1;
    }
  }
  return 0;
}

void host_log_info(const char *message) {
  plugin_string_t level = {0};
  plugin_string_t msg = {0};
  plugin_string_set(&level, "info");
  plugin_string_set(&msg, message);
  hanga_engine_host_log(&level, &msg);
}

void greet_peers(void) {
  plugin_list_string_t peers = {.ptr = NULL, .len = 0};
  hanga_engine_host_peers(&peers);
  for (size_t i = 0; i < peers.len; i++) {
    plugin_string_t method = {0};
    hanga_engine_host_value_t args = {0};
    plugin_string_set(&method, "hello");
    payload_empty(&args);
    hanga_engine_host_send(&peers.ptr[i], &method, &args);
    hanga_engine_host_value_free(&args);
  }
  plugin_list_string_free(&peers);
}

int topic_eq(const plugin_string_t *topic, const char *want) {
  const char *ptr = topic && topic->ptr ? (const char *)topic->ptr : "";
  size_t len = topic ? topic->len : 0;
  return str_eq_n(ptr, len, want);
}
