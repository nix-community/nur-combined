{ lib, stdenv

, fetchFromGitHub

, rustPlatform

, darwin
}:
rustPlatform.buildRustPackage rec {
  pname = "streampager";
  version = "0.10.3";

  src = fetchFromGitHub {
    owner = "markbt";
    repo = "streampager";
    rev = "v${version}";
    hash = "sha256-xOFm/tjZBkkUa/Q5SStZSX++oTgd+ncY47dg5Ryvjo4=";
  };

  cargoHash = "sha256-rUSyMzCro2VY10zmJembE80o9MaG+uqx21zzfUnxNAQ=";

  buildInputs = lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
    CoreFoundation
    CoreServices
  ]);

  meta = with lib; {
    description = "A pager for command output or large files";
    homepage = "https://github.com/markbt/streampager";
    license = licenses.mit;
    mainProgram = "streampager";
  };
}
