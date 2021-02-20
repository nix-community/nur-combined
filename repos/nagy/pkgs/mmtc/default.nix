{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "mmtc";
  version = "0.2.13";

  src = fetchFromGitHub {
    owner = "figsoda";
    repo = pname;
    rev = "v${version}";
    sha256 = "0ag87hgdg6fvk80fgznba0xjlcajks5w5s6y8lvwhz9irn2kq2rz";
  };

  cargoSha256 = "06xqh0mqbik00qyg8mn1ddbn15v3pdwvh1agghg22xgx53kmnxb3";

  meta = with lib; {
    description = "Minimal mpd terminal client that aims to be simple yet highly configurable";
    homepage = "https://github.com/figsoda/mmtc";
    license = licenses.mpl20;
    maintainers = [ ];
    changelog = "https://raw.githubusercontent.com/figsoda/mmtc/v${version}/CHANGELOG.md";
  };
}
