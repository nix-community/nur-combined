/* test.c — exercises the sasso C ABI (FFI v2) against the prebuilt dylib.
 *
 * Build (from this directory, ffi/examples/c/):
 *   clang test.c -I ../../include -L ../../target/release -lsasso -o test
 * Run:
 *   DYLD_LIBRARY_PATH=../../target/release ./test
 *
 * Covers the 5 checks from the shared spec, including the v2 custom importer.
 */
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>

#include "sasso.h"

static int g_pass = 0;
static int g_fail = 0;

/* Report a single check; `ok` decides PASS/FAIL. */
static void check(int n, const char *name, int ok) {
  if (ok) {
    printf("Check %d (%s): PASS\n", n, name);
    g_pass++;
  } else {
    printf("Check %d (%s): FAIL\n", n, name);
    g_fail++;
  }
}

/* Compare a SassoResult's css bytes against an expected NUL-terminated string,
 * honoring the explicit byte length (binary-safe). */
static int css_equals(const SassoResult *r, const char *expected) {
  size_t elen = strlen(expected);
  if (!r || !r->ok || r->css == NULL) return 0;
  if (r->css_len != elen) return 0;
  return memcmp(r->css, expected, elen) == 0;
}

/* ---- in-memory file map for the v2 importer (check 5) ---- */
typedef struct {
  const char *key; /* canonical key */
  const char *src; /* stylesheet source */
} Entry;

static const Entry FILE_MAP[] = {
    {"/sub/_mod", "$c: #336699;\n"},
};
static const size_t FILE_MAP_LEN = sizeof(FILE_MAP) / sizeof(FILE_MAP[0]);

static const char *map_lookup(const char *key) {
  for (size_t i = 0; i < FILE_MAP_LEN; i++) {
    if (strcmp(FILE_MAP[i].key, key) == 0) return FILE_MAP[i].src;
  }
  return NULL;
}

/* Join `dir` (canonical dir of the importing file, e.g. "/") with a relative
 * `url` (e.g. "sub/mod"). Writes a NUL-terminated path into `out`. Very small:
 * just ensures exactly one '/' between dir and url. */
static void join_path(const char *dir, const char *url, char *out, size_t cap) {
  size_t dl = strlen(dir);
  /* drop a trailing slash on dir so we control the separator */
  if (dl > 0 && dir[dl - 1] == '/') dl--;
  snprintf(out, cap, "%.*s/%s", (int)dl, dir, url);
}

/* Given a candidate canonical path like "/sub/mod", produce its partial form
 * "/sub/_mod" (prefix the last segment with '_'). */
static void to_partial(const char *path, char *out, size_t cap) {
  const char *slash = strrchr(path, '/');
  if (!slash) {
    snprintf(out, cap, "_%s", path);
    return;
  }
  size_t head = (size_t)(slash - path) + 1; /* include the slash */
  snprintf(out, cap, "%.*s_%s", (int)head, path, slash + 1);
}

/* Compute the directory of a canonical url. For "/entry" -> "/". */
static void dir_of(const char *url, char *out, size_t cap) {
  const char *slash = strrchr(url, '/');
  if (!slash) {
    snprintf(out, cap, "%s", ".");
    return;
  }
  if (slash == url) { /* root-level, e.g. "/entry" */
    snprintf(out, cap, "/");
    return;
  }
  size_t head = (size_t)(slash - url);
  snprintf(out, cap, "%.*s", (int)head, url);
}

/* canonicalize(): resolve `url` relative to ctx->containing_url's dir, trying
 * the plain join then the partial (_-prefixed) form. */
static int32_t my_canonicalize(void *ud, const char *url,
                               const SassoCanonicalizeContext *ctx,
                               SassoImporterSink *sink) {
  (void)ud;
  char dir[1024];
  const char *containing = (ctx && ctx->containing_url) ? ctx->containing_url : "/";
  dir_of(containing, dir, sizeof(dir));

  char plain[1024];
  join_path(dir, url, plain, sizeof(plain));

  /* try the plain join */
  if (map_lookup(plain) != NULL) {
    sasso_importer_set_canonical(sink, plain, strlen(plain));
    return SASSO_IMPORTER_OK;
  }
  /* try the partial (_-prefixed last segment) */
  char partial[1024];
  to_partial(plain, partial, sizeof(partial));
  if (map_lookup(partial) != NULL) {
    sasso_importer_set_canonical(sink, partial, strlen(partial));
    return SASSO_IMPORTER_OK;
  }
  return SASSO_IMPORTER_NOT_FOUND;
}

/* load(): fetch the canonical key's source from the map. */
static int32_t my_load(void *ud, const char *canonical, SassoImporterSink *sink) {
  (void)ud;
  const char *src = map_lookup(canonical);
  if (src == NULL) return SASSO_IMPORTER_NOT_FOUND;
  sasso_importer_set_result(sink, src, strlen(src), SASSO_SYNTAX_SCSS, NULL, 0);
  return SASSO_IMPORTER_OK;
}

int main(void) {
  /* ---- Check 1: version ---- */
  const char *ver = sasso_version();
  printf("sasso_version() = \"%s\"\n", ver ? ver : "(null)");
  check(1, "version looks like a semver", ver != NULL && isdigit((unsigned char)ver[0]) && strchr(ver, '.') != NULL);

  /* ---- Check 2: default compile (NULL opts) ---- */
  {
    const char *src = ".a { color: red; &:hover { color: blue; } }";
    const char *expected =
        ".a {\n  color: red;\n}\n.a:hover {\n  color: blue;\n}";
    SassoResult *r = sasso_compile(src, strlen(src), NULL);
    int ok = css_equals(r, expected);
    if (!ok && r) {
      printf("  got css (len=%zu): <<<%.*s>>>\n", r->css_len,
             (int)r->css_len, r->css ? r->css : "");
    }
    check(2, "default expanded compile", ok);
    sasso_result_free(r);
  }

  /* ---- Check 3: compressed compile ---- */
  {
    SassoOptions opts;
    sasso_options_init(&opts, sizeof(SassoOptions));
    opts.style = SASSO_STYLE_COMPRESSED;
    const char *src = ".a { color: #336699; }";
    const char *expected = ".a{color:#369}";
    SassoResult *r = sasso_compile(src, strlen(src), &opts);
    int ok = css_equals(r, expected);
    if (!ok && r) {
      printf("  got css (len=%zu): <<<%.*s>>>\n", r->css_len,
             (int)r->css_len, r->css ? r->css : "");
    }
    check(3, "compressed compile", ok);
    sasso_result_free(r);
  }

  /* ---- Check 4: error path ---- */
  {
    const char *src = ".a { color: ";
    SassoResult *r = sasso_compile(src, strlen(src), NULL);
    int ok = r != NULL && r->ok == 0 && r->error != NULL &&
             r->error_len > 0 && r->error_line >= 1;
    if (r && r->error) {
      /* print only the first line of the diagnostic */
      const char *nl = strchr(r->error, '\n');
      int first_len = nl ? (int)(nl - r->error) : (int)r->error_len;
      printf("  first error line (line=%u col=%u): %.*s\n",
             r->error_line, r->error_column, first_len, r->error);
    }
    check(4, "error path (ok==0, error set, line>=1)", ok);
    sasso_result_free(r);
  }

  /* ---- Check 5: v2 custom importer ---- */
  {
    SassoImporter importer;
    importer.user_data = NULL;
    importer.canonicalize = my_canonicalize;
    importer.load = my_load;

    SassoOptions opts;
    sasso_options_init(&opts, sizeof(SassoOptions));
    opts.url = "/entry";
    opts.importer = &importer;

    const char *src = "@use \"sub/mod\" as m;\n.out { color: m.$c; }\n";
    const char *expected = ".out {\n  color: #336699;\n}";
    SassoResult *r = sasso_compile(src, strlen(src), &opts);
    int ok = css_equals(r, expected);
    if (r && !r->ok && r->error) {
      printf("  importer compile error (line=%u): %s\n", r->error_line, r->error);
    } else if (!ok && r) {
      printf("  got css (len=%zu): <<<%.*s>>>\n", r->css_len,
             (int)r->css_len, r->css ? r->css : "");
    }
    check(5, "v2 custom importer (@use across importer)", ok);
    sasso_result_free(r);
  }

  printf("\n%d passed, %d failed\n", g_pass, g_fail);
  return g_fail == 0 ? 0 : 1;
}
