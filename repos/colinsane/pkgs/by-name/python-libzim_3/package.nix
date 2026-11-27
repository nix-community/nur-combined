{
  fetchFromGitHub,
  gitUpdater,
  libzim,
  python3,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "python-libzim";
  version = "3.13.1";

  src = fetchFromGitHub {
    owner = "openzim";
    repo = "python-libzim";
    tag = "v${finalAttrs.version}";
    hash = "sha256-y2TwLRVeDkeFdad9WzA39gCG6JB2T6KFRHiLgvAGRis=";
  };

  # patches = [
  #   (fetchurl {
  #     # relaxes the cython/setuptools/wheel pyproject dependencies
  #     # but does not apply to 3.13.1 tag
  #     url = "https://github.com/openzim/python-libzim/commit/a39aa6e8800f375c9663fca0f9149d4c00c2920f.patch?full_index=1";
  #     name = "Relax-build-dependency-pins-to-floor-ceiling-ranges";
  #   })
  # ];

  nativeBuildInputs = [
    # pkg-config
    python3  # to set the correct "_PYTHON_HOST_PLATFORM" env, as required by cython
    python3.pkgs.cython
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  buildInputs = [
    libzim
  ];

  # kill the `find_library("zim")` call: it tries to dlopen libzim.so (via ctypes) and fails when cross compiling.
  # in fact it's just a "sanity check" and not fed into anything; libzim is found for real elsewhere.
  # relax build-time dependencies: nixpkgs' are older. same effect as a39aa6e8800f375c9663fca0f9149d4c00c2920f (does not apply cleanly)
  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'return find_library("zim") or ""' 'return "(provided by ld wrapper)"'
    substituteInPlace pyproject.toml \
      --replace-fail 'cython == 3.3.0' 'cython >= 3.3.0' \
      --replace-fail 'setuptools == 84.0.0' 'setuptools >= 83.0.0' \
      --replace-fail 'wheel == 0.48.0' 'wheel >= 0.47.0'
  '';

  env.USE_SYSTEM_LIBZIM = "1";

  strictDeps = true;
  __structuredAttrs = true;

  passthru = {
    pythonModule = python3;
    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };
})
