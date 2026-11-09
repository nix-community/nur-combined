{
  lib,
  fetchFromGitHub,
  rustPlatform,
  rustc,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  cacert,
  gitMinimal,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "provenant";
  version = "1.0.17";

  src = fetchFromGitHub {
    owner = "getprovenant";
    repo = "provenant";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MxF6JscT6kNKBGIBn0enJK3/YNMUogqTn3IueBZYtKs=";
  };

  cargoHash = "sha256-hvXcOZTinZ4GHcDztPTdINVkTL+e56tDPOJpe1ktuU8=";

  # The test suite takes half an hour and more memory than the build itself,
  # so it runs from passthru.tests.cargo rather than as part of the build.
  doCheck = false;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;

  passthru = {
    tests.cargo = finalAttrs.finalPackage.overrideAttrs (prevAttrs: {
      doCheck = true;
      doInstallCheck = false;
      dontBuild = true;
      dontFixup = true;
      installPhase = "touch $out";

      nativeCheckInputs = [
        cacert
        gitMinimal
        writableTmpDirAsHomeHook
      ];
      cargoTestFlags = [ "--no-fail-fast" ];

      # Each test binary is a large link taking over a gigabyte of memory, and
      # linking them all at once exhausts a builder with limited memory. Avoid
      # the release profile's fat LTO, drop debuginfo, and limit how many run
      # at once.
      cargoCheckType = "debug";
      env = prevAttrs.env or { } // {
        CARGO_PROFILE_DEV_DEBUG = "0";
      };
      preCheck = ''
        export NIX_BUILD_CORES=$((NIX_BUILD_CORES < 4 ? NIX_BUILD_CORES : 4))
        # buildRustPackage sets this to the empty string, which silences the
        # log messages that the tests check for.
        unset RUST_LOG
      '';
      # Several test modules build their own copy of the license index, and
      # doing that concurrently uses as much memory as the links do.
      dontUseCargoParallelTests = true;
    });
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Fast Rust scanner for provenance data";
    homepage = "https://getprovenant.dev/";
    changelog = "https://github.com/getprovenant/provenant/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "provenant";
    inherit (rustc.meta) platforms;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
