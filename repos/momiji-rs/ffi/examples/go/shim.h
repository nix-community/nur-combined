/* shim.h — C-side glue for the Go cgo binding.
 *
 * cgo cannot store a Go function pointer into a C struct, so we expose two
 * plain-C trampolines (go_canonicalize / go_load) whose addresses ARE valid C
 * function pointers. Each trampoline forwards to a //export'ed Go function
 * (declared in _cgo_export.h, which this header is included alongside).
 *
 * make_importer() returns a heap SassoImporter wired to those trampolines;
 * free_importer() releases it. user_data is unused here (the Go side keeps the
 * in-memory file map in a package-level map), so we pass NULL.
 */
#ifndef SASSO_GO_SHIM_H
#define SASSO_GO_SHIM_H

#include "sasso.h"

/* C trampolines with the exact SassoImporter callback signatures. */
int32_t go_canonicalize(void *user_data, const char *url,
                        const SassoCanonicalizeContext *ctx,
                        SassoImporterSink *sink);
int32_t go_load(void *user_data, const char *canonical, SassoImporterSink *sink);

/* Build / free a SassoImporter pointing at the trampolines above. */
SassoImporter *make_importer(void);
void free_importer(SassoImporter *imp);

#endif /* SASSO_GO_SHIM_H */
