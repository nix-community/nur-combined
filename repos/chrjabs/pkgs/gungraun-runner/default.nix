{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  coreutils,
}:
rustPlatform.buildRustPackage rec {
  pname = "gungraun-runner";
  version = "0.19.4";

  src = fetchFromGitHub {
    owner = "gungraun";
    repo = "gungraun";
    tag = "v${version}";
    hash = "sha256-KWQ4wMNIdKY9FTmPd9ZdlSuCpQQBFhIKD2Ereo3JQaI=";
  };

  cargoHash = "sha256-+3toaUDLCmExC3EvNv1GEdUbHSBeShurp2Y+zvE/t0k=";

  buildAndTestSubdir = "gungraun-runner";

  postPatch = ''
    substituteInPlace gungraun-runner/src/runner/args.rs \
      --replace-fail "/bin/cat" "${lib.getExe' coreutils "cat"}"
  '';

  meta = with lib; {
    description = "High-precision, one-shot and consistent benchmarking framework/harness for Rust. All Valgrind tools at your fingertips.";
    mainProgram = "gungraun-runner";
    homepage = "https://gungraun.github.io/gungraun/latest/html/index.html";
    license = with licenses; [
      mit
      asl20
    ];
    maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
  };
}
