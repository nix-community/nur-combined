{
  lib,
  stdenv,
  fetchFromGitHub,
  zig_0_16,
  nix-update-script,
}:

stdenv.mkDerivation (
  finalAttrs:
  {
    pname = "nearme";
    version = "0.3.0";

    src = fetchFromGitHub {
      owner = "georgemandis";
      repo = "nearme";
      tag = "v${finalAttrs.version}";
      # The v0.3.0 tree predates upstream's build.zig.zon, which Zig 0.16
      # rejects when the fingerprint is missing.
      hash = "sha256-5V8MxSMYwOm1Q8Yb01Q9visTs+pIsFFu4QeOt+ymUOE=";
    };

    nativeBuildInputs = [ zig_0_16 ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-global-cache
      export ZIG_LOCAL_CACHE_DIR=$TMPDIR/zig-local-cache
      # Zig links against the host SDK's libobjc/MapKit; the Nix apple-sdk does
      # not ship libobjc, so drop stdenv's SDK/DEVELOPER_DIR and its -L flags.
      # Keep the environment changes local so the fixup phase still sees the
      # Nix toolchain.
      env -u SDKROOT -u DEVELOPER_DIR -u NIX_LDFLAGS -u NIX_CFLAGS_COMPILE \
        PATH="/usr/bin:$PATH" \
        zig build -Doptimize=ReleaseSafe --prefix "$out" --summary all

      runHook postBuild
    '';

    # zig build already installed the binary.
    installPhase = ''
      runHook preInstall
      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      "$out/bin/nearme" --version
      runHook postInstallCheck
    '';

    passthru.updateScript = nix-update-script { };

    meta = {
      description = "Search for places near coordinates using macOS MapKit";
      homepage = "https://github.com/georgemandis/nearme";
      changelog = "https://github.com/georgemandis/nearme/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.mit;
      mainProgram = "nearme";
      # MapKit has no equivalent on other platforms.
      platforms = lib.platforms.darwin;
    };
  }
  // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Zig discovers the macOS SDK and system frameworks outside the Nix store;
    # the darwin sandbox only exposes a fixed set of system paths.
    __noChroot = true;
  }
)
