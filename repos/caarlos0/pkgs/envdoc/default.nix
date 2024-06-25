{ lib
, buildGoModule
, fetchFromGitHub
}:
buildGoModule rec {
  pname = "envdoc";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "g4s8";
    repo = "envdoc";
    rev = "v${version}";
    hash = "sha256-oimI9sGfM8u2vmdmrLwAgwbTN5t9y3hCx2Fzh2gH/CE=";
  };

  vendorHash = null;

  doCheck = false;

  meta = with lib; {
    description = "Go tool to generate documentation for environment variables";
    homepage = "https://github.com/g4s8/envdoc";
    changelog = "https://github.com/g4s8/envdoc/commits";
    maintainers = with maintainers; [ caarlos0 ];
    mainProgram = "envdoc";
  };
}
