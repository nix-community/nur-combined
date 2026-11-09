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
  nix-update-script,
}:
rustPlatform.buildRustPackage (
  finalAttrs:
  let
    gitCommit = builtins.substring 0 12 finalAttrs.src.rev;
    gitDate = builtins.substring 11 (-1) finalAttrs.version;
    landlockPolicyFromClosure = callPackage ./landlockPolicyFromClosure.nix { };
  in
  {
    pname = "landlock-policy";
    version = "0-unstable-2026-11-05";
    __structuredAttrs = true;
    strictDeps = true;

    src = fetchFromGitHub {
      owner = "landlock-lsm";
      repo = "landlock-policy";
      rev = "b91aaaac53661943f8d30fb1f7f4e2f6d2dc3479";
      hash = "sha256-06OrbE7D9myXN2VEMzKPHAxE3Mv1XPMtO7+aHhyRE7k=";
    };

    cargoHash = "sha256-CyPAJDtc27QF/eBXITLFgVhq3iDotiEiEKesPZusBrs=";

    nativeBuildInputs = [
      cargo-c
      validatePkgConfig
    ];

    cargoBuildFlags = [
      "--package=landlock-exec"
      "--package=landlock-policy-cli"
    ];

    postPatch = ''
      for p in landlock-exec landlock-policy-cli; do
        cat > $p/build.rs <<EOF
      fn main() {
        println!("cargo:rustc-env=GIT_COMMIT=${gitCommit}");
        println!("cargo:rustc-env=GIT_DATE=${gitDate}");
      }
      EOF
      done
    '';

    postBuild = ''
      ${buildPackages.rust.envVars.setEnv} cargo cbuild --release --frozen \
        --package=landlock-policy-ffi \
        --prefix=$out \
        --target=${stdenv.hostPlatform.rust.rustcTarget}
    '';

    postInstall = ''
      ${buildPackages.rust.envVars.setEnv} cargo cinstall --release --frozen \
        --package=landlock-policy-ffi \
        --prefix=$out \
        --target=${stdenv.hostPlatform.rust.rustcTarget}
    '';

    passthru = {
      updateScript = nix-update-script {
        extraArgs = [ "--version=branch" ];
      };

      inherit landlockPolicyFromClosure;

      tests = {
        config-from-closure = callPackage ./landlockPolicyFromClosure-test.nix {
          inherit landlockPolicyFromClosure;
          landlock-policy = finalAttrs.finalPackage;
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
      downloadPage = "https://github.com/landlock-lsm/landlock-policy";
      license = lib.licenses.OR [
        lib.licenses.mit
        lib.licenses.asl20
      ];
      platforms = lib.platforms.linux;
      pkgConfigModules = [ "landlock-policy" ];
      mainProgram = "landlock-policy";
      maintainers = [ lib.maintainers.skyesoss ];
    };
  }
)
