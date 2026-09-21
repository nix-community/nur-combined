#ifndef LINK_H
#define LINK_H
struct r_debug {};
typedef struct { int d_tag; union { void* d_ptr; } d_un; } ElfW_Dyn;
#define ElfW(type) ElfW_##type
#define DT_DEBUG 21
#endif
