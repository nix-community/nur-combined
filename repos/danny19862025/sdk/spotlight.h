#ifndef SPOTLIGHT_PLUGIN_H
#define SPOTLIGHT_PLUGIN_H
/* ABI v1. wasm32 pointers and lengths; no WASI imports. See docs/WASM.md. */
#ifdef __cplusplus
extern "C" {
#endif
__attribute__((import_module("spotlight"), import_name("request_len")))
int spotlight_request_len(void);
__attribute__((import_module("spotlight"), import_name("read_request")))
int spotlight_read_request(unsigned char *buffer, int capacity);
__attribute__((import_module("spotlight"), import_name("emit")))
void spotlight_emit(const unsigned char *json, int length);
/* Export void spotlight_run(void) and linear memory named "memory". */
void spotlight_run(void);
#ifdef __cplusplus
}
#endif
#endif
