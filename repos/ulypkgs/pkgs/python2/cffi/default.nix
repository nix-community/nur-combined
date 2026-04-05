{
  lib,
  stdenv,
  buildPythonPackage,
  isPyPy,
  fetchPypi,
  fetchpatch,
  pytestCheckHook,
  libffi,
  pkg-config,
  pycparser,
  pythonAtLeast,
}:

if isPyPy then
  null
else
  buildPythonPackage rec {
    pname = "cffi";
    version = "1.15.1";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-1AC/uaN7E1ElPLQCZxzqfom97MKU6AFqcH9tHYrJNPk=";
    };

    patches = [
      #
      # Trusts the libffi library inside of nixpkgs on Apple devices.
      #
      # Based on some analysis I did:
      #
      #   https://groups.google.com/g/python-cffi/c/xU0Usa8dvhk
      #
      # I believe that libffi already contains the code from Apple's fork that is
      # deemed safe to trust in cffi.
      #
      ./darwin-use-libffi-closures.diff
      (fetchpatch {
        # Drop py.code usage from tests, no longer depend on the deprecated py package
        url = "https://foss.heptapod.net/pypy/cffi/-/commit/9c7d865e17ec16a847090a3e0d1498b698b99756.patch";
        excludes = [
          "README.md"
          "requirements.txt"
        ];
        hash = "sha256-HSuLLIYXXGGCPccMNLV7o1G3ppn2P0FGCrPjqDv2e7k=";
      })
      (fetchpatch {
        #  Replace py.test usage with pytest
        url = "https://foss.heptapod.net/pypy/cffi/-/commit/bd02e1b122612baa74a126e428bacebc7889e897.patch";
        excludes = [
          "README.md"
          "requirements.txt"
        ];
        hash = "sha256-+2daRTvxtyrCPimOEAmVbiVm1Bso9hxGbaAbd03E+ws=";
      })
    ]
    ++ lib.optionals (stdenv.cc.isClang && lib.versionAtLeast (lib.getVersion stdenv.cc) "13") [
      # -Wnull-pointer-subtraction is enabled with -Wextra. Suppress it to allow the following tests
      # to run and pass when cffi is built with newer versions of clang:
      # - testing/cffi1/test_verify1.py::test_enum_usage
      # - testing/cffi1/test_verify1.py::test_named_pointer_as_argument
      ./clang-pointer-substraction-warning.diff
    ]
    ++ lib.optionals (pythonAtLeast "3.11") [
      # Fix test that failed because python seems to have changed the exception format in the
      # final release. This patch should be included in the next version and can be removed when
      # it is released.
      (fetchpatch {
        url = "https://foss.heptapod.net/pypy/cffi/-/commit/8a3c2c816d789639b49d3ae867213393ed7abdff.diff";
        hash = "sha256-3wpZeBqN4D8IP+47QDGK7qh/9Z0Ag4lAe+H0R5xCb1E=";
      })
    ];

    postPatch = lib.optionalString stdenv.isDarwin ''
      # Remove setup.py impurities
      substituteInPlace setup.py \
        --replace "'-iwithsysroot/usr/include/ffi'" "" \
        --replace "'/usr/include/ffi'," "" \
        --replace '/usr/include/libffi' '${lib.getDev libffi}/include'
    '';

    buildInputs = [ libffi ];

    nativeBuildInputs = [ pkg-config ];

    propagatedBuildInputs = [ pycparser ];

    # The tests use -Werror but with python3.6 clang detects some unreachable code.
    env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-unused-command-line-argument -Wno-unreachable-code -Wno-c++11-narrowing";

    doCheck = !stdenv.hostPlatform.isMusl;

    nativeCheckInputs = [ pytestCheckHook ];

    disabledTests = lib.optionals stdenv.isDarwin [
      # cannot load library 'c'
      "test_FILE"
      "test_FILE_object"
      "test_FILE_only_for_FILE_arg"
      "test_load_and_call_function"
      "test_load_library"

      # cannot load library 'dl'
      "test_dlopen_handle"

      # cannot load library 'm'
      "test_dir_on_dlopen_lib"
      "test_dlclose"
      "test_dlopen"
      "test_dlopen_constant"
      "test_dlopen_flags"
      "test_function_typedef"
      "test_line_continuation_in_defines"
      "test_missing_function"
      "test_remove_comments"
      "test_remove_line_continuation_comments"
      "test_simple"
      "test_sin"
      "test_sinf"
      "test_stdcall_only_on_windows"
      "test_wraps_from_stdlib"

      # MemoryError
      "test_callback_as_function_argument"
      "test_callback_crash"
      "test_callback_decorator"
      "test_callback_large_struct"
      "test_callback_returning_void"
      "test_cast_functionptr_and_int"
      "test_function_pointer"
      "test_functionptr_intptr_return"
      "test_functionptr_simple"
      "test_functionptr_void_return"
      "test_functionptr_voidptr_return"
    ];

    meta = with lib; {
      maintainers = with maintainers; [
        domenkozar
        lnl7
      ];
      homepage = "https://cffi.readthedocs.org/";
      license = licenses.mit;
      description = "Foreign Function Interface for Python calling C code";
    };
  }
