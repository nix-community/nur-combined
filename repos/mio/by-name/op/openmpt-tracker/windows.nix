{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  wine,
  msvc-wine-toolchain,
}:

let
  # Wine's server checks a Mach port in with the bootstrap namespace, which the
  # darwin Nix sandbox denies ("Can't check in server_mach_port"), so no Wine
  # process can start inside it — not even with __darwinAllowLocalNetworking.
  # The whole build runs cl.exe/link.exe under Wine, so darwin builds without
  # the sandbox (Linux keeps it).
  buildIsDarwin = stdenv.buildPlatform.isDarwin;
in
stdenv.mkDerivation (
  finalAttrs:
  {
    pname = "openmpt-tracker-windows";
    version = "0.8.10";

    src = fetchFromGitHub {
      owner = "OpenMPT";
      repo = "openmpt";
      rev = "libopenmpt-${finalAttrs.version}";
      hash = "sha256-N7EZqfM9U+1F0R4S0kT6MTbWxVTH2T7NE7nuKEaKl5s=";
    };

    # cl/lib/link/rc are run under Wine; python3 drives the project graph.
    nativeBuildInputs = [
      python3
      wine
    ];

    dontConfigure = true;
    dontStrip = true;

    buildPhase = ''
      runHook preBuild

      export HOME="$TMPDIR/wine-home"
      export WINEPREFIX="$TMPDIR/wineprefix"
      export WINEARCH=win64
      export WINEDEBUG="-all"
      mkdir -p "$HOME" "$WINEPREFIX"
      wine boot --init || true
      wineserver -w || true

      # The wrappers translate unix paths to z:/... themselves; MSVC_ROOT is what
      # build.py uses to locate the static MFC libraries (afxnmcd plus the
      # charset's uafxcw) and libcmt.
      export MSVC_ROOT="${msvc-wine-toolchain}"
      export PATH="$MSVC_ROOT/bin/x64:$PATH"

      python3 ${./build.py} \
        --src . \
        --out "$TMPDIR/build" \
        --jobs "$NIX_BUILD_CORES" \
        --all

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm644 LICENSE "$out/share/doc/${finalAttrs.pname}/LICENSE"
      mkdir -p "$out/share/openmpt-tracker"
      # The DLLs are the mpg123/lame projects the GUI links against
      # (LINK_MPG123_DLL), so they have to ship next to the exe.
      cp -a "$TMPDIR"/build/bin/. "$out/share/openmpt-tracker/"
      rm -f "$out/share/openmpt-tracker/OpenMPT.pdb"
      runHook postInstall
    '';

    # The output is Windows PE but the derivation is built on the host, so
    # leave `platforms` out: nixpkgs would otherwise check this nested drv
    # against the host platform while the wrapper is evaluated.
    meta = {
      description = "OpenMPT tracker Windows build (real MSVC + MFC under Wine)";
      homepage = "https://openmpt.org/";
      license = lib.licenses.bsd3;
    };
  }
  // lib.optionalAttrs buildIsDarwin {
    # Wine needs the sandbox off on darwin (see buildIsDarwin); omitting the
    # attribute entirely elsewhere leaves Linux's sandbox alone.
    __noChroot = true;
  }
)
