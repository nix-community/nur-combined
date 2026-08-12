{
  lib,
  stdenv,
  buildPackages,
  callPackage,
  rustPlatform,
  fetchFromGitHub,
  cargo-c,
  validatePkgConfig,
  testers,
}:
rustPlatform.buildRustPackage (
  finalAttrs:
  let
    gitCommit = builtins.substring 0 12 finalAttrs.src.rev;
    gitDate = builtins.substring 11 (-1) finalAttrs.version;
    landlockConfigFromClosure = callPackage ./landlockConfigFromClosure.nix { };
  in
  {
    pname = "landlockconfig";
    version = "0-unstable-2026-07-22";

    src = fetchFromGitHub {
      owner = "landlock-lsm";
      repo = "landlockconfig";
      rev = "bdffdcd14e6c5fb8c0b014ee8a7df897fafcb8e2";
      hash = "sha256-MgXAikH8H7wPJKRFu7TH50JDOXTNaxdgMXgDrQ/E+LY=";
    };

    cargoHash = "sha256-abRwcJqLm4UD1Bn7ZnxO/5R3xyVA5Hb1fisw5/bYE3g=";

    nativeBuildInputs = [
      cargo-c
      validatePkgConfig
    ];

    cargoBuildFlags = [
      "--package=llconfig"
    ];

    postPatch = ''
      cat > llconfig/build.rs <<EOF
      fn main() {
        println!("cargo:rustc-env=GIT_COMMIT=${gitCommit}");
        println!("cargo:rustc-env=GIT_DATE=${gitDate}");
      }
      EOF
    '';

    postBuild = ''
      ${buildPackages.rust.envVars.setEnv} cargo cbuild --release --frozen \
        --package=landlockconfig_ffi \
        --prefix=$out \
        --target=${stdenv.hostPlatform.rust.rustcTarget}
    '';

    postInstall = ''
      ${buildPackages.rust.envVars.setEnv} cargo cinstall --release --frozen \
        --package=landlockconfig_ffi \
        --prefix=$out \
        --target=${stdenv.hostPlatform.rust.rustcTarget}
    '';

    passthru = {
      inherit landlockConfigFromClosure;

      tests = {
        config-from-closure = callPackage ./landlockConfigFromClosure-test.nix {
          inherit landlockConfigFromClosure;
          landlockconfig = finalAttrs.finalPackage;
        };
        pkg-config = testers.hasPkgConfigModules {
          package = finalAttrs.finalPackage;
        };
        version = testers.testVersion {
          package = finalAttrs.finalPackage;
          version = "${gitCommit} ${gitDate}";
        };
      };
    };

    meta = {
      description = "Landlock configuration library";
      homepage = "https://landlock.io";
      downloadPage = "https://github.com/landlock-lsm/landlockconfig";
      license = lib.licenses.OR [
        lib.licenses.mit
        lib.licenses.asl20
      ];
      platforms = lib.platforms.linux;
      pkgConfigModules = [ "landlockconfig" ];
      mainProgram = "llconfig";
      maintainers = [ lib.maintainers.skyesoss ];
    };
  }
)
