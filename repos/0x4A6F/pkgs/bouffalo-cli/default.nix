{ pkgs, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "bouffalo-cli";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "mkroman";
    repo = "bouffalo-cli";
    rev = "v${version}";
    sha256 = "0qg4hnr5ddqc5xbigk2jrmfkc9knzrgzcdy6zizpymzpv7r6hk6x";
  };

  cargoSha256 = "sha256:08qbk0slcv375fxlkbz1cwsbb06phagdi14cwggfv5y512l3r6qv";

  meta = with pkgs.lib; {
    description = "BL602 Boot ROM utility";
    homepage = "https://github.com/mkroman/bouffalo-cli";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ _0x4A6F ];
  };
}
