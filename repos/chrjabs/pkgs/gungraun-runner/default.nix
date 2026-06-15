{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  coreutils,
}:
rustPlatform.buildRustPackage rec {
  pname = "gungraun-runner";
  version = "0.19.2";

  src = fetchFromGitHub {
    owner = "gungraun";
    repo = "gungraun";
    tag = "v${version}";
    hash = "sha256-irDfxyW/yrTGmQH0r4tKc6lvDUQNkPBnvuW/nlh8uko=";
  };

  cargoHash = "sha256-IiNaSXOxEv9fcONz5vjuJeDEvlDBFfY+Cm8hT9C/GLk=";

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
