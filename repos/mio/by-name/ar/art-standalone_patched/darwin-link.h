#ifndef ART_DARWIN_LINK_H_
#define ART_DARWIN_LINK_H_
#include <elf.h>
#include <stddef.h>
#include <stdint.h>
#ifndef ElfW
#if defined(__LP64__)
#define ElfW(type) Elf64_##type
#else
#define ElfW(type) Elf32_##type
#endif
#endif
struct dl_phdr_info {
  ElfW(Addr) dlpi_addr;
  const char *dlpi_name;
  const ElfW(Phdr) *dlpi_phdr;
  ElfW(Half) dlpi_phnum;
};
static inline int dl_iterate_phdr(
    int (*callback)(struct dl_phdr_info *, size_t, void *), void *data) {
  (void)callback;
  (void)data;
  return 0;
}
#endif
