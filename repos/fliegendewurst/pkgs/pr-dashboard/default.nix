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
    rev = "18aa20b89c5da4b5a765abfbd764ef9ef5222108";
    hash = "sha256-mbrn8KbTBpGeW77QQ8WZxv0CtcqP9JuSodfh6mwhIx8=";
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
