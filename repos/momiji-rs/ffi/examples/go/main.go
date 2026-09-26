// Idiomatic Go (cgo) binding + conformance test for the sasso C ABI (FFI v2).
//
// Build/run (the go.mod is committed — no `go mod init` needed):
//
//	cd ffi/examples/go
//	DYLD_LIBRARY_PATH=../../target/release LD_LIBRARY_PATH=../../target/release go run .   # macOS / Linux
//
// We link against the prebuilt libsasso (already built — do NOT cargo build).
// cgo expands ${SRCDIR} to this file's directory, so the include/lib paths
// resolve relative to ffi/examples/go/ regardless of the working directory.
package main

/*
#cgo CFLAGS: -I${SRCDIR}/../../include
#cgo LDFLAGS: -L${SRCDIR}/../../target/release -lsasso
#include <stdlib.h>
#include "sasso.h"
#include "shim.h"
*/
import "C"

import (
	"fmt"
	"os"
	"strings"
	"unsafe"
)

// ---- In-memory virtual filesystem for the custom importer (check 5) ----
//
// Keyed by canonical URL. Kept package-level so the //export callbacks can see
// it without juggling user_data pointers across the C boundary.
var fileMap = map[string]string{
	"/sub/_mod": "$c: #336699;\n",
}

// dirOf returns the directory portion of a "/"-style canonical URL.
// "/entry" -> "/", "/sub/_mod" -> "/sub/".
func dirOf(url string) string {
	i := strings.LastIndex(url, "/")
	if i < 0 {
		return "/"
	}
	return url[:i+1]
}

// resolve joins a (possibly relative) url against base's directory and tries the
// plain key, then the partial (`_`-prefixed last segment). Returns ("", false)
// if neither key exists in the map.
func resolve(url, containing string) (string, bool) {
	var joined string
	if strings.HasPrefix(url, "/") {
		joined = url
	} else {
		joined = dirOf(containing) + url
	}
	// 1) plain join, e.g. /sub/mod
	if _, ok := fileMap[joined]; ok {
		return joined, true
	}
	// 2) partial: prefix the LAST path segment with '_', e.g. /sub/_mod
	slash := strings.LastIndex(joined, "/")
	partial := joined[:slash+1] + "_" + joined[slash+1:]
	if _, ok := fileMap[partial]; ok {
		return partial, true
	}
	return "", false
}

//export Canonicalize
func Canonicalize(url *C.char, ctx *C.SassoCanonicalizeContext, sink *C.SassoImporterSink) C.int32_t {
	goURL := C.GoString(url)
	containing := "/"
	if ctx != nil && ctx.containing_url != nil {
		containing = C.GoString(ctx.containing_url)
	}
	canonical, ok := resolve(goURL, containing)
	if !ok {
		return C.SASSO_IMPORTER_NOT_FOUND // 0
	}
	cb := []byte(canonical)
	C.sasso_importer_set_canonical(sink, (*C.char)(unsafe.Pointer(&cb[0])), C.size_t(len(cb)))
	return C.SASSO_IMPORTER_OK // 1
}

//export Load
func Load(canonical *C.char, sink *C.SassoImporterSink) C.int32_t {
	src, ok := fileMap[C.GoString(canonical)]
	if !ok {
		return C.SASSO_IMPORTER_NOT_FOUND // 0
	}
	sb := []byte(src)
	var ptr *C.char
	if len(sb) > 0 {
		ptr = (*C.char)(unsafe.Pointer(&sb[0]))
	}
	C.sasso_importer_set_result(sink, ptr, C.size_t(len(sb)),
		C.SASSO_SYNTAX_SCSS, nil, 0)
	return C.SASSO_IMPORTER_OK // 1
}

// ---- Idiomatic compile wrapper ----

type compileResult struct {
	ok     bool
	css    string
	errMsg string
	line   int
	column int
}

// compile runs src through sasso. opts may be nil for all-defaults.
func compile(src string, opts *C.SassoOptions) compileResult {
	csrc := C.CString(src)
	defer C.free(unsafe.Pointer(csrc))

	res := C.sasso_compile(csrc, C.size_t(len(src)), opts)
	defer C.sasso_result_free(res)

	if res.ok != 0 {
		return compileResult{
			ok:  true,
			css: C.GoStringN(res.css, C.int(res.css_len)),
		}
	}
	return compileResult{
		ok:     false,
		errMsg: C.GoStringN(res.error, C.int(res.error_len)),
		line:   int(res.error_line),
		column: int(res.error_column),
	}
}

// ---- Test harness ----

var allPass = true

func check(n int, name string, pass bool, detail string) {
	status := "PASS"
	if !pass {
		status = "FAIL"
		allPass = false
	}
	fmt.Printf("Check %d [%s] %s — %s\n", n, status, name, detail)
}

func qq(s string) string { return fmt.Sprintf("%q", s) }

func main() {
	// Check 1: version
	ver := C.GoString(C.sasso_version())
	check(1, "sasso_version()", len(strings.Split(ver, ".")) >= 3, "got "+qq(ver)+", want a semver")

	// Check 2: default (NULL opts) nested-selector expansion
	want2 := ".a {\n  color: red;\n}\n.a:hover {\n  color: blue;\n}"
	r2 := compile(".a { color: red; &:hover { color: blue; } }", nil)
	check(2, "default compile", r2.ok && r2.css == want2,
		"got "+qq(r2.css))

	// Check 3: compressed style
	var opts C.SassoOptions
	C.sasso_options_init(&opts, C.size_t(unsafe.Sizeof(opts)))
	opts.style = C.SASSO_STYLE_COMPRESSED
	want3 := ".a{color:#369}"
	r3 := compile(".a { color: #336699; }", &opts)
	check(3, "compressed compile", r3.ok && r3.css == want3,
		"got "+qq(r3.css))

	// Check 4: error path
	r4 := compile(".a { color: ", nil)
	firstLine := r4.errMsg
	if i := strings.IndexByte(firstLine, '\n'); i >= 0 {
		firstLine = firstLine[:i]
	}
	pass4 := !r4.ok && len(r4.errMsg) > 0 && r4.line >= 1
	check(4, "error path", pass4,
		fmt.Sprintf("ok=%v line=%d err1=%s", r4.ok, r4.line, qq(firstLine)))

	// Check 5: v2 custom importer
	var iopts C.SassoOptions
	C.sasso_options_init(&iopts, C.size_t(unsafe.Sizeof(iopts)))
	entryURL := C.CString("/entry")
	defer C.free(unsafe.Pointer(entryURL))
	iopts.url = entryURL
	imp := C.make_importer()
	defer C.free_importer(imp)
	iopts.importer = imp

	entry := "@use \"sub/mod\" as m;\n.out { color: m.$c; }\n"
	want5 := ".out {\n  color: #336699;\n}"
	r5 := compile(entry, &iopts)
	detail5 := "got " + qq(r5.css)
	if !r5.ok {
		detail5 = fmt.Sprintf("compile error (line %d): %s", r5.line, qq(r5.errMsg))
	}
	check(5, "v2 custom importer", r5.ok && r5.css == want5, detail5)

	if allPass {
		fmt.Println("\nALL CHECKS PASSED")
	} else {
		fmt.Println("\nSOME CHECKS FAILED")
		os.Exit(1)
	}
}
