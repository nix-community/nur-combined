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

    # MSBuild drives upstream's committed .vcxproj files; the tools it invokes
    # (cl/lib/link/rc) are Windows PE binaries and run under Wine.
    nativeBuildInputs = [ wine ];

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

      # Upstream's own build: MSBuild over the committed project files. The
      # properties pin what this toolchain carries (its toolset directory is
      # v145 and its SDK is 10.0.26100.0, while the projects ask for v143 and
      # 10.0.22621.0), skip the UAP SDK check the payload cannot satisfy, and
      # turn off Spectre-mitigated libraries, which are a separate component.
      # UseEnv makes MSBuild take the wrapper's INCLUDE and LIB instead of
      # recomputing them, which is what leaves the UCRT out otherwise.
      # Serial on purpose: with /m the concurrent cl.exe instances under Wine
      # die and MSBuild reports an empty "0 Error(s) ... FAILED", which reads as
      # a build error in projects that build fine on their own.
      export PATH="${msvc-wine-toolchain}/bin/x64:$PATH"
      msbuild build/vs2022win10/OpenMPT.vcxproj \
        /nologo \
        /p:Configuration=Release \
        /p:Platform=x64 \
        /p:UseEnv=true \
        /p:PlatformToolset=v145 \
        /p:WindowsTargetPlatformVersion=10.0.26100.0 \
        /p:WindowsSDKInstalled=true \
        /p:WindowsSDK_Desktop_Support=true \
        /p:SpectreMitigation=false

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm644 LICENSE "$out/share/doc/${finalAttrs.pname}/LICENSE"
      mkdir -p "$out/share/openmpt-tracker"
      # The DLLs are the mpg123/lame projects the GUI links against
      # (LINK_MPG123_DLL), so they have to ship next to the exe.
      # MSBuild also leaves .pdb/.lib/.exp link artifacts next to the exe; ship
      # only the binary and the two DLLs it loads at runtime.
      install -m755 bin/release/vs2022-win10-static/amd64/OpenMPT.exe "$out/share/openmpt-tracker/"
      install -m644 \
        bin/release/vs2022-win10-static/amd64/openmpt-mpg123.dll \
        bin/release/vs2022-win10-static/amd64/openmpt-lame.dll \
        "$out/share/openmpt-tracker/"
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
