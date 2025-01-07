{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
  makeBinaryWrapper,
  sqlite,
}:

rustPlatform.buildRustPackage rec {
  pname = "pr-dashboard";
  version = "0-unstable";

  src = fetchFromGitHub {
    owner = "FliegendeWurst";
    repo = "pr-dashboard";
    rev = "d4c78cbabdc59600d7ed9c4e83c7430d199b8409";
    hash = "sha256-X/UL6A+Yj8Ha+C8f5tA8yHQC/QC1UfYd8yvhifu6M8E=";
  };

  cargoHash = "sha256-IKy/iKkom3PylIjJdLLgROzL0GMmSRLL31t+svCf1io=";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    makeBinaryWrapper
  ];
  buildInputs = [ sqlite ];

  postInstall = ''
    wrapProgram $out/bin/pr-dashboard \
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ sqlite ]}"
  '';

  doInstallCheck = false;
  doCheck = false;

  meta = with lib; {
    description = "PR dashboard for nixpkgs";
    homepage = "https://github.com/FliegendeWurst/pr-dashboard";
    license = with licenses; [ gpl3Plus ];
    maintainers = with maintainers; [ fliegendewurst ];
    mainProgram = "pr-dashboard";
  };
}
