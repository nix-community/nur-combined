{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  coreutils,
}:
rustPlatform.buildRustPackage rec {
  pname = "gungraun-runner";
  version = "0.19.3";

  src = fetchFromGitHub {
    owner = "gungraun";
    repo = "gungraun";
    tag = "v${version}";
    hash = "sha256-jT7CVJxwy4sBE9KSA/D1ImN47MmQtToZ0qwHIZ3v+pQ=";
  };

  cargoHash = "sha256-kJsKGZ1EAdONfEggkvlpniDwSI30+sUG6zud5xVc5CM=";

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
