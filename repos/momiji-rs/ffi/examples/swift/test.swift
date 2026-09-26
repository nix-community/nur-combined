// Swift binding example/test for the sasso C ABI (FFI v2).
//
// Build (from this directory, ffi/examples/swift/):
//   swiftc -I . -L ../../target/release -lsasso test.swift -o test
// Run:
//   DYLD_LIBRARY_PATH=../../target/release ./test
//
// `import CSasso` is provided by the local module.modulemap (which references
// the curated ffi/include/sasso.h). All C functions/structs come from there.

import CSasso

#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

// ---------------------------------------------------------------------------
// Small helpers around the C ABI
// ---------------------------------------------------------------------------

/// Read a (ptr, len) UTF-8 byte buffer into a Swift String honoring the length.
func string(fromBytes ptr: UnsafeMutablePointer<CChar>?, len: Int) -> String? {
    guard let ptr = ptr else { return nil }
    let raw = UnsafeRawPointer(ptr).assumingMemoryBound(to: UInt8.self)
    let buffer = UnsafeBufferPointer(start: raw, count: len)
    return String(decoding: buffer, as: UTF8.self)
}

var passCount = 0
var failCount = 0

func check(_ name: String, _ condition: Bool, detail: String = "") {
    if condition {
        passCount += 1
        print("PASS \(name)")
    } else {
        failCount += 1
        print("FAIL \(name)\(detail.isEmpty ? "" : " — \(detail)")")
    }
}

/// Quote a string for legible diagnostics (show newlines as \n).
func q(_ s: String?) -> String {
    guard let s = s else { return "<nil>" }
    let escaped = s.split(separator: "\n", omittingEmptySubsequences: false).joined(separator: "\\n")
    return "\"" + escaped + "\""
}

// ===========================================================================
// Check 1 — sasso_version() looks like a version
// ===========================================================================

let versionPtr = sasso_version()
let version = versionPtr.map { String(cString: $0) } ?? "<nil>"
check("1 version", version.split(separator: ".").count >= 3, detail: "got \(q(version))")

// ===========================================================================
// Check 2 — default compile (NULL opts) of nested rule
// ===========================================================================

do {
    let src = ".a { color: red; &:hover { color: blue; } }"
    let expected = ".a {\n  color: red;\n}\n.a:hover {\n  color: blue;\n}"
    let bytes = Array(src.utf8)
    let result = bytes.withUnsafeBufferPointer { buf in
        buf.baseAddress!.withMemoryRebound(to: CChar.self, capacity: buf.count) { p in
            sasso_compile(p, buf.count, nil)
        }
    }
    defer { sasso_result_free(result) }
    let r = result!.pointee
    let css = string(fromBytes: r.css, len: r.css_len)
    check("2 default-compile", r.ok == 1 && css == expected,
          detail: "ok=\(r.ok) css=\(q(css))")
}

// ===========================================================================
// Check 3 — compressed compile (style=1)
// ===========================================================================

do {
    let src = ".a { color: #336699; }"
    let expected = ".a{color:#369}"
    var opts = SassoOptions()
    sasso_options_init(&opts, MemoryLayout<SassoOptions>.size)
    opts.style = SASSO_STYLE_COMPRESSED
    let bytes = Array(src.utf8)
    let result = bytes.withUnsafeBufferPointer { buf in
        buf.baseAddress!.withMemoryRebound(to: CChar.self, capacity: buf.count) { p in
            sasso_compile(p, buf.count, &opts)
        }
    }
    defer { sasso_result_free(result) }
    let r = result!.pointee
    let css = string(fromBytes: r.css, len: r.css_len)
    check("3 compressed", r.ok == 1 && css == expected,
          detail: "ok=\(r.ok) css=\(q(css))")
}

// ===========================================================================
// Check 4 — error path
// ===========================================================================

do {
    let src = ".a { color: "
    let bytes = Array(src.utf8)
    let result = bytes.withUnsafeBufferPointer { buf in
        buf.baseAddress!.withMemoryRebound(to: CChar.self, capacity: buf.count) { p in
            sasso_compile(p, buf.count, nil)
        }
    }
    defer { sasso_result_free(result) }
    let r = result!.pointee
    let error = string(fromBytes: r.error, len: r.error_len)
    let firstLine = error?.split(separator: "\n", maxSplits: 1).first.map(String.init) ?? "<none>"
    check("4 error-path",
          r.ok == 0 && (error?.isEmpty == false) && r.error_line >= 1,
          detail: "ok=\(r.ok) line=\(r.error_line) err=\(q(error))")
    print("     first error line: \(firstLine)")
}

// ===========================================================================
// Check 5 — v2 custom importer
// ===========================================================================
//
// @convention(c) callbacks cannot capture Swift state, so the in-memory file
// map lives in a global. We still route through user_data to demonstrate the
// ABI (and to keep the importer self-describing), but the lookup table itself
// is the process-global `fileMap`.

let fileMap: [String: String] = [
    "/sub/_mod": "$c: #336699;\n"
]

/// Resolve `url` relative to the directory of `containing`, dart-sass style:
/// try the plain join, then the partial (`_`-prefixed last segment).
func canonicalCandidates(forURL url: String, containing: String?) -> [String] {
    // Directory of the containing URL ("/entry" -> "/").
    let dir: String
    if let containing = containing, let slash = containing.lastIndex(of: "/") {
        dir = String(containing[...slash]) // includes trailing slash
    } else {
        dir = "/"
    }
    // Join dir + url, collapsing the boundary slash.
    let joined: String
    if url.hasPrefix("/") {
        joined = url
    } else if dir.hasSuffix("/") {
        joined = dir + url
    } else {
        joined = dir + "/" + url
    }
    // Partial variant: prefix the last path segment with '_'.
    let partial: String
    if let slash = joined.lastIndex(of: "/") {
        let head = joined[...slash]
        let tail = joined[joined.index(after: slash)...]
        partial = String(head) + "_" + String(tail)
    } else {
        partial = "_" + joined
    }
    return [joined, partial]
}

// canonicalize callback: top-level @convention(c) function (no captures).
let canonicalizeFn: @convention(c) (
    UnsafeMutableRawPointer?, UnsafePointer<CChar>?,
    UnsafePointer<SassoCanonicalizeContext>?, OpaquePointer?
) -> Int32 = { _, urlPtr, ctxPtr, sink in
    guard let urlPtr = urlPtr else { return SASSO_IMPORTER_NOT_FOUND }
    let url = String(cString: urlPtr)
    var containing: String? = nil
    if let ctx = ctxPtr?.pointee, let cu = ctx.containing_url {
        containing = String(cString: cu)
    }
    for candidate in canonicalCandidates(forURL: url, containing: containing) {
        if fileMap[candidate] != nil {
            let bytes = Array(candidate.utf8)
            bytes.withUnsafeBufferPointer { buf in
                buf.baseAddress!.withMemoryRebound(to: CChar.self, capacity: buf.count) { p in
                    sasso_importer_set_canonical(sink, p, buf.count)
                }
            }
            return SASSO_IMPORTER_OK
        }
    }
    return SASSO_IMPORTER_NOT_FOUND
}

// load callback.
let loadFn: @convention(c) (
    UnsafeMutableRawPointer?, UnsafePointer<CChar>?, OpaquePointer?
) -> Int32 = { _, canonPtr, sink in
    guard let canonPtr = canonPtr else { return SASSO_IMPORTER_NOT_FOUND }
    let canonical = String(cString: canonPtr)
    guard let src = fileMap[canonical] else { return SASSO_IMPORTER_NOT_FOUND }
    let bytes = Array(src.utf8)
    bytes.withUnsafeBufferPointer { buf in
        buf.baseAddress!.withMemoryRebound(to: CChar.self, capacity: buf.count) { p in
            sasso_importer_set_result(sink, p, buf.count, SASSO_SYNTAX_SCSS, nil, 0)
        }
    }
    return SASSO_IMPORTER_OK
}

do {
    let entry = "@use \"sub/mod\" as m;\n.out { color: m.$c; }\n"
    let expected = ".out {\n  color: #336699;\n}"

    var importer = SassoImporter()
    importer.user_data = nil
    importer.canonicalize = canonicalizeFn
    importer.load = loadFn

    let urlCStr = strdup("/entry")
    defer { free(urlCStr) }

    let bytes = Array(entry.utf8)
    let result: UnsafeMutablePointer<SassoResult>? = withUnsafePointer(to: &importer) { impPtr in
        var opts = SassoOptions()
        sasso_options_init(&opts, MemoryLayout<SassoOptions>.size)
        opts.url = UnsafePointer(urlCStr)
        opts.importer = impPtr
        return bytes.withUnsafeBufferPointer { buf in
            buf.baseAddress!.withMemoryRebound(to: CChar.self, capacity: buf.count) { p in
                sasso_compile(p, buf.count, &opts)
            }
        }
    }
    defer { sasso_result_free(result) }
    let r = result!.pointee
    let css = string(fromBytes: r.css, len: r.css_len)
    let err = string(fromBytes: r.error, len: r.error_len)
    check("5 v2-importer", r.ok == 1 && css == expected,
          detail: "ok=\(r.ok) css=\(q(css)) err=\(q(err))")
}

// ---------------------------------------------------------------------------

print("---")
print("\(passCount) passed, \(failCount) failed")
exit(failCount == 0 ? 0 : 1)
