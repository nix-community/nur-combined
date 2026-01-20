{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "gungraun-runner";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "gungraun";
    repo = "gungraun";
    tag = "v${version}";
    hash = "sha256-8AuC5AqsiqXFomIEVPbRh1aYf/HQRg7oEVGiH6gdHFg=";
  };

  cargoHash = "sha256-ERBYOFMkd+jy6u/mpSCvm0GMOYPYRO6ZwH9iVhttJng=";

  buildAndTestSubdir = "gungraun-runner";

  checkFlags = [
    "--skip test_runner_binary::test_version::test_library_version_equals_runner_version"
    "--skip test_runner_binary::test_version::test_library_version_newer_than_runner_version::case_1_major"
    "--skip test_runner_binary::test_version::test_library_version_newer_than_runner_version::case_2_minor"
    "--skip test_runner_binary::test_version::test_library_version_newer_than_runner_version::case_3_patch"
    "--skip test_runner_binary::test_version::test_library_version_not_submitted"
    "--skip test_runner_binary::test_version::test_library_version_older_than_runner_version"
  ];

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
