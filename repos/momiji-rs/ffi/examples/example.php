<?php
// Using the sasso C ABI from PHP via ext-ffi (no compiled PHP extension).
//
//   cargo build --release      # in ffi/, produces target/release/libsasso.{so,dylib}
//   php examples/example.php
//
// PHP's FFI::cdef() does not run the C preprocessor, so the declarations below
// are the plain (macro-free) subset of include/sasso.h.

declare(strict_types=1);

$lib = PHP_OS_FAMILY === 'Darwin'
    ? __DIR__ . '/../target/release/libsasso.dylib'
    : __DIR__ . '/../target/release/libsasso.so';

$ffi = FFI::cdef(<<<'CDEF'
typedef struct SassoOptions {
  uint32_t struct_size;
  int32_t style;
  int32_t syntax;
  int32_t unicode;
  const char *url;
  const char *const *load_paths;
  size_t load_paths_len;
} SassoOptions;

typedef struct SassoResult {
  int32_t ok;
  char *css;
  size_t css_len;
  char *error;
  size_t error_len;
  uint32_t error_line;
  uint32_t error_column;
} SassoResult;

const char *sasso_version(void);
void sasso_options_init(SassoOptions *options, size_t struct_size);
SassoResult *sasso_compile(const char *source, size_t source_len, const SassoOptions *options);
void sasso_result_free(SassoResult *result);
CDEF, $lib);

const SASSO_STYLE_COMPRESSED = 1;

/** Compile $scss, optionally compressed; returns the CSS or throws on error. */
function sasso_compile(FFI $ffi, string $scss, bool $compressed = false): string
{
    $opts = $ffi->new('SassoOptions');
    $ffi->sasso_options_init(FFI::addr($opts), FFI::sizeof($opts));
    if ($compressed) {
        $opts->style = SASSO_STYLE_COMPRESSED;
    }

    $res = $ffi->sasso_compile($scss, strlen($scss), FFI::addr($opts));
    try {
        if ($res->ok) {
            return FFI::string($res->css, $res->css_len);
        }
        throw new RuntimeException(
            FFI::string($res->error, $res->error_len),
            // line/column are available as $res->error_line / $res->error_column
        );
    } finally {
        $ffi->sasso_result_free($res);
    }
}

echo "sasso ", FFI::string($ffi->sasso_version()), "\n\n";

echo sasso_compile($ffi, '.a { color: red; &:hover { color: blue; } }'), "\n";
echo sasso_compile($ffi, '.a { color: rgba(var(--x), 0.5); }', compressed: true), "\n\n";

try {
    sasso_compile($ffi, '.a { color: ');
} catch (RuntimeException $e) {
    echo "caught: ", explode("\n", $e->getMessage())[0], "\n";
}
