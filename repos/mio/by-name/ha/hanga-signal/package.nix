{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "hanga-signal";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "johanhelsing";
    repo = "matchbox";
    rev = "v${version}";
    hash = "sha256-NlmGUXroKh+SXvXSecjNka0t4SaxWbUL8XFXkkXKK+U=";
  };

  cargoHash = "sha256-YeCncI51oO2r2gphdtQ3GRulu7x2XeXiSrcWxn3J+dE=";

  buildAndTestSubdir = "matchbox_server";

  doCheck = false;

  postInstall = ''
    ln -s matchbox_server $out/bin/hanga-signal
  '';

  meta = {
    description = "Matchbox signaling server for Hanga multiplayer (port 3536)";
    homepage = "https://github.com/johanhelsing/matchbox";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "hanga-signal";
  };
}
