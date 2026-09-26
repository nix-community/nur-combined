// Program.cs — exercises the sasso C ABI (FFI v2) from C# via P/Invoke.
//
// Build & run (from this directory):
//   dotnet run -c Release
//
// We load the prebuilt dylib through a NativeLibrary.SetDllImportResolver. The
// path is resolved portably: SASSO_DYLIB env override, else by searching upward
// from the running binary for ffi/target/release/libsasso.dylib. No need to copy
// the dylib or set DYLD_LIBRARY_PATH. Covers the 5 checks from the shared spec,
// including the v2 custom importer.

using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

namespace SassoExample
{
    // ---- ABI structs (must match ffi/include/sasso.h byte-for-byte) ----

    [StructLayout(LayoutKind.Sequential)]
    internal struct SassoCanonicalizeContext
    {
        public int from_import;        // int32_t
        public IntPtr containing_url;  // const char* (NUL-terminated, or NULL at entry)
    }

    [StructLayout(LayoutKind.Sequential)]
    internal struct SassoImporter
    {
        public IntPtr user_data;                  // void*
        public IntPtr canonicalize;               // fn ptr (set from a delegate)
        public IntPtr load;                       // fn ptr (set from a delegate)
    }

    [StructLayout(LayoutKind.Sequential)]
    internal struct SassoOptions
    {
        public uint struct_size;        // uint32_t
        public int style;               // int32_t  (0=expanded, 1=compressed)
        public int syntax;              // int32_t  (0=scss, 1=sass, 2=css)
        public int unicode;             // int32_t
        public IntPtr url;              // const char*
        public IntPtr load_paths;       // const char* const*
        public UIntPtr load_paths_len;  // size_t
        public IntPtr importer;         // const SassoImporter*
    }

    [StructLayout(LayoutKind.Sequential)]
    internal struct SassoResult
    {
        public int ok;                  // int32_t (1=success)
        public IntPtr css;              // char*
        public UIntPtr css_len;         // size_t
        public IntPtr error;            // char*
        public UIntPtr error_len;       // size_t
        public uint error_line;         // uint32_t
        public uint error_column;       // uint32_t
    }

    // Importer callback delegate types (Cdecl, matching the header).
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    internal delegate int CanonicalizeFn(IntPtr userData, IntPtr url, IntPtr ctx, IntPtr sink);

    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    internal delegate int LoadFn(IntPtr userData, IntPtr canonical, IntPtr sink);

    internal static class Native
    {
        // Logical name; resolved to the absolute dylib path via the resolver below.
        public const string Lib = "sasso";

        public const int SASSO_STYLE_EXPANDED = 0;
        public const int SASSO_STYLE_COMPRESSED = 1;
        public const int SASSO_SYNTAX_SCSS = 0;

        public const int SASSO_IMPORTER_OK = 1;
        public const int SASSO_IMPORTER_NOT_FOUND = 0;
        public const int SASSO_IMPORTER_ERROR = -1;

        [DllImport(Lib, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr sasso_version();

        [DllImport(Lib, CallingConvention = CallingConvention.Cdecl)]
        public static extern void sasso_options_init(ref SassoOptions options, UIntPtr structSize);

        [DllImport(Lib, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr sasso_compile(IntPtr source, UIntPtr sourceLen, IntPtr options);

        [DllImport(Lib, CallingConvention = CallingConvention.Cdecl)]
        public static extern void sasso_result_free(IntPtr result);

        [DllImport(Lib, CallingConvention = CallingConvention.Cdecl)]
        public static extern void sasso_importer_set_canonical(IntPtr sink, IntPtr ptr, UIntPtr len);

        [DllImport(Lib, CallingConvention = CallingConvention.Cdecl)]
        public static extern void sasso_importer_set_result(
            IntPtr sink, IntPtr contents, UIntPtr contentsLen,
            int syntax, IntPtr sourceMapUrl, UIntPtr sourceMapUrlLen);

        [DllImport(Lib, CallingConvention = CallingConvention.Cdecl)]
        public static extern void sasso_importer_set_error(IntPtr sink, IntPtr ptr, UIntPtr len);
    }

    internal static class Program
    {
        // Resolve the prebuilt library portably: an explicit SASSO_DYLIB env var
        // wins; otherwise walk up from the running binary (bin/Release/netX/) to
        // find ffi/target/release/libsasso.{dylib,so} (or sasso.dll on Windows).
        private static string ResolveDylibPath()
        {
            string env = Environment.GetEnvironmentVariable("SASSO_DYLIB");
            if (!string.IsNullOrEmpty(env))
                return env;

            // Match cargo's per-OS artifact name.
            string libName = RuntimeInformation.IsOSPlatform(OSPlatform.Windows) ? "sasso.dll"
                : RuntimeInformation.IsOSPlatform(OSPlatform.OSX) ? "libsasso.dylib"
                : "libsasso.so";
            string relative = Path.Combine("ffi", "target", "release", libName);
            DirectoryInfo dir = new DirectoryInfo(AppContext.BaseDirectory);
            while (dir != null)
            {
                string candidate = Path.Combine(dir.FullName, relative);
                if (File.Exists(candidate))
                    return candidate;
                dir = dir.Parent;
            }
            throw new FileNotFoundException(
                $"Could not locate {relative} by searching upward from {AppContext.BaseDirectory}. " +
                "Set SASSO_DYLIB to override.");
        }

        private static int _pass = 0;
        private static int _fail = 0;

        private static void Check(int n, string name, bool ok)
        {
            if (ok)
            {
                Console.WriteLine($"Check {n} ({name}): PASS");
                _pass++;
            }
            else
            {
                Console.WriteLine($"Check {n} ({name}): FAIL");
                _fail++;
            }
        }

        // ---- UTF-8 marshalling helpers ----

        // Allocate a NUL-terminated UTF-8 buffer in unmanaged memory. Caller frees.
        private static IntPtr Utf8Alloc(string s)
        {
            byte[] bytes = Encoding.UTF8.GetBytes(s);
            IntPtr p = Marshal.AllocHGlobal(bytes.Length + 1);
            Marshal.Copy(bytes, 0, p, bytes.Length);
            Marshal.WriteByte(p, bytes.Length, 0);
            return p;
        }

        // Read `len` bytes at `ptr` as a UTF-8 string (binary-safe, honors length).
        private static string Utf8Read(IntPtr ptr, ulong len)
        {
            if (ptr == IntPtr.Zero || len == 0) return string.Empty;
            int n = checked((int)len);
            byte[] bytes = new byte[n];
            Marshal.Copy(ptr, bytes, 0, n);
            return Encoding.UTF8.GetString(bytes);
        }

        private static string Version()
        {
            IntPtr p = Native.sasso_version();
            return p == IntPtr.Zero ? null : Marshal.PtrToStringUTF8(p);
        }

        // Compile `src`; returns the SassoResult struct (copied out) plus the raw
        // result pointer so the caller can free it.
        private static (SassoResult res, IntPtr raw) Compile(string src, IntPtr optsPtr)
        {
            byte[] srcBytes = Encoding.UTF8.GetBytes(src);
            IntPtr srcPtr = Marshal.AllocHGlobal(srcBytes.Length == 0 ? 1 : srcBytes.Length);
            try
            {
                Marshal.Copy(srcBytes, 0, srcPtr, srcBytes.Length);
                IntPtr raw = Native.sasso_compile(srcPtr, (UIntPtr)srcBytes.Length, optsPtr);
                SassoResult res = Marshal.PtrToStructure<SassoResult>(raw);
                return (res, raw);
            }
            finally
            {
                Marshal.FreeHGlobal(srcPtr);
            }
        }

        private static string CssOf(SassoResult r) => Utf8Read(r.css, (ulong)r.css_len);
        private static string ErrorOf(SassoResult r) => Utf8Read(r.error, (ulong)r.error_len);

        // ---- check 5: in-memory file map + relative resolution ----

        private static readonly Dictionary<string, string> FileMap = new()
        {
            { "/sub/_mod", "$c: #336699;\n" },
        };

        private static string DirOf(string url)
        {
            int slash = url.LastIndexOf('/');
            if (slash < 0) return ".";
            if (slash == 0) return "/"; // root-level, e.g. "/entry"
            return url.Substring(0, slash);
        }

        private static string JoinPath(string dir, string url)
        {
            if (dir.Length > 0 && dir[dir.Length - 1] == '/')
                dir = dir.Substring(0, dir.Length - 1);
            return dir + "/" + url;
        }

        private static string ToPartial(string path)
        {
            int slash = path.LastIndexOf('/');
            if (slash < 0) return "_" + path;
            return path.Substring(0, slash + 1) + "_" + path.Substring(slash + 1);
        }

        // Roots for the importer delegates so the GC can't collect them while the
        // native compile call is reaching back into managed code.
        private static CanonicalizeFn _canonicalizeDel;
        private static LoadFn _loadDel;

        private static int Canonicalize(IntPtr userData, IntPtr urlPtr, IntPtr ctxPtr, IntPtr sink)
        {
            string url = Marshal.PtrToStringUTF8(urlPtr) ?? "";
            string containing = "/";
            if (ctxPtr != IntPtr.Zero)
            {
                SassoCanonicalizeContext ctx = Marshal.PtrToStructure<SassoCanonicalizeContext>(ctxPtr);
                if (ctx.containing_url != IntPtr.Zero)
                    containing = Marshal.PtrToStringUTF8(ctx.containing_url) ?? "/";
            }

            string dir = DirOf(containing);
            string plain = JoinPath(dir, url);

            string chosen = null;
            if (FileMap.ContainsKey(plain))
            {
                chosen = plain;
            }
            else
            {
                string partial = ToPartial(plain);
                if (FileMap.ContainsKey(partial)) chosen = partial;
            }

            if (chosen == null) return Native.SASSO_IMPORTER_NOT_FOUND;

            IntPtr buf = Utf8Alloc(chosen);
            try
            {
                int byteLen = Encoding.UTF8.GetByteCount(chosen);
                Native.sasso_importer_set_canonical(sink, buf, (UIntPtr)byteLen);
            }
            finally
            {
                Marshal.FreeHGlobal(buf); // sasso copies immediately, so we own/free this
            }
            return Native.SASSO_IMPORTER_OK;
        }

        private static int Load(IntPtr userData, IntPtr canonicalPtr, IntPtr sink)
        {
            string canonical = Marshal.PtrToStringUTF8(canonicalPtr) ?? "";
            if (!FileMap.TryGetValue(canonical, out string src))
                return Native.SASSO_IMPORTER_NOT_FOUND;

            IntPtr buf = Utf8Alloc(src);
            try
            {
                int byteLen = Encoding.UTF8.GetByteCount(src);
                Native.sasso_importer_set_result(
                    sink, buf, (UIntPtr)byteLen, Native.SASSO_SYNTAX_SCSS, IntPtr.Zero, UIntPtr.Zero);
            }
            finally
            {
                Marshal.FreeHGlobal(buf);
            }
            return Native.SASSO_IMPORTER_OK;
        }

        private static int Main()
        {
            // Resolve the logical "sasso" name to the dylib path (portably).
            string dylibPath = ResolveDylibPath();
            NativeLibrary.SetDllImportResolver(typeof(Program).Assembly, (name, asm, search) =>
                name == Native.Lib ? NativeLibrary.Load(dylibPath) : IntPtr.Zero);

            // ---- Check 1: version ----
            string ver = Version();
            Console.WriteLine($"sasso_version() = \"{ver ?? "(null)"}\"");
            Check(1, "version looks like a semver", System.Text.RegularExpressions.Regex.IsMatch(ver ?? "", @"^\d+\.\d+\.\d+"));

            // ---- Check 2: default compile (NULL opts) ----
            {
                string src = ".a { color: red; &:hover { color: blue; } }";
                string expected = ".a {\n  color: red;\n}\n.a:hover {\n  color: blue;\n}";
                var (r, raw) = Compile(src, IntPtr.Zero);
                bool ok = r.ok != 0 && CssOf(r) == expected;
                if (!ok) Console.WriteLine($"  got css (len={(ulong)r.css_len}): <<<{CssOf(r)}>>>");
                Check(2, "default expanded compile", ok);
                Native.sasso_result_free(raw);
            }

            // ---- Check 3: compressed compile ----
            {
                SassoOptions opts = default;
                Native.sasso_options_init(ref opts, (UIntPtr)Marshal.SizeOf<SassoOptions>());
                opts.style = Native.SASSO_STYLE_COMPRESSED;

                IntPtr optsPtr = Marshal.AllocHGlobal(Marshal.SizeOf<SassoOptions>());
                try
                {
                    Marshal.StructureToPtr(opts, optsPtr, false);
                    string src = ".a { color: #336699; }";
                    string expected = ".a{color:#369}";
                    var (r, raw) = Compile(src, optsPtr);
                    bool ok = r.ok != 0 && CssOf(r) == expected;
                    if (!ok) Console.WriteLine($"  got css (len={(ulong)r.css_len}): <<<{CssOf(r)}>>>");
                    Check(3, "compressed compile", ok);
                    Native.sasso_result_free(raw);
                }
                finally
                {
                    Marshal.FreeHGlobal(optsPtr);
                }
            }

            // ---- Check 4: error path ----
            {
                string src = ".a { color: ";
                var (r, raw) = Compile(src, IntPtr.Zero);
                bool ok = r.ok == 0 && r.error != IntPtr.Zero
                          && (ulong)r.error_len > 0 && r.error_line >= 1;
                if (r.error != IntPtr.Zero)
                {
                    string err = ErrorOf(r);
                    int nl = err.IndexOf('\n');
                    string first = nl >= 0 ? err.Substring(0, nl) : err;
                    Console.WriteLine($"  first error line (line={r.error_line} col={r.error_column}): {first}");
                }
                Check(4, "error path (ok==0, error set, line>=1)", ok);
                Native.sasso_result_free(raw);
            }

            // ---- Check 5: v2 custom importer ----
            {
                _canonicalizeDel = Canonicalize;
                _loadDel = Load;

                SassoImporter importer = default;
                importer.user_data = IntPtr.Zero;
                importer.canonicalize = Marshal.GetFunctionPointerForDelegate(_canonicalizeDel);
                importer.load = Marshal.GetFunctionPointerForDelegate(_loadDel);

                IntPtr importerPtr = Marshal.AllocHGlobal(Marshal.SizeOf<SassoImporter>());
                IntPtr urlPtr = Utf8Alloc("/entry");
                IntPtr optsPtr = Marshal.AllocHGlobal(Marshal.SizeOf<SassoOptions>());
                try
                {
                    Marshal.StructureToPtr(importer, importerPtr, false);

                    SassoOptions opts = default;
                    Native.sasso_options_init(ref opts, (UIntPtr)Marshal.SizeOf<SassoOptions>());
                    opts.url = urlPtr;
                    opts.importer = importerPtr;
                    Marshal.StructureToPtr(opts, optsPtr, false);

                    string src = "@use \"sub/mod\" as m;\n.out { color: m.$c; }\n";
                    string expected = ".out {\n  color: #336699;\n}";
                    var (r, raw) = Compile(src, optsPtr);
                    bool ok = r.ok != 0 && CssOf(r) == expected;
                    if (r.ok == 0 && r.error != IntPtr.Zero)
                        Console.WriteLine($"  importer compile error (line={r.error_line}): {ErrorOf(r)}");
                    else if (!ok)
                        Console.WriteLine($"  got css (len={(ulong)r.css_len}): <<<{CssOf(r)}>>>");
                    Check(5, "v2 custom importer (@use across importer)", ok);
                    Native.sasso_result_free(raw);

                    GC.KeepAlive(_canonicalizeDel);
                    GC.KeepAlive(_loadDel);
                }
                finally
                {
                    Marshal.FreeHGlobal(optsPtr);
                    Marshal.FreeHGlobal(urlPtr);
                    Marshal.FreeHGlobal(importerPtr);
                }
            }

            Console.WriteLine();
            Console.WriteLine($"{_pass} passed, {_fail} failed");
            return _fail == 0 ? 0 : 1;
        }
    }
}
