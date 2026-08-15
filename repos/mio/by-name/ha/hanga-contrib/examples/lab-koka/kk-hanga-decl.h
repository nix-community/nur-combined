#pragma once
#include <kklib.h>
#include <stdbool.h>
#include <stdint.h>

void kk_hanga_payload_text(intptr_t ret, kk_string_t s, kk_context_t *ctx);
void kk_hanga_payload_flag(intptr_t ret, bool value, kk_context_t *ctx);
void kk_hanga_payload_empty(intptr_t ret, kk_context_t *ctx);
void kk_hanga_payload_gravity(intptr_t ret, kk_context_t *ctx);
void kk_hanga_payload_fracture(intptr_t ret, kk_context_t *ctx);
void kk_hanga_payload_methods(intptr_t ret, kk_context_t *ctx);
int32_t kk_hanga_bag_int32(intptr_t payload, kk_string_t key, kk_context_t *ctx);
bool kk_hanga_bag_text_eq(intptr_t payload, kk_string_t key, kk_string_t want, kk_context_t *ctx);
bool kk_hanga_bus_has(intptr_t payload, kk_context_t *ctx);
