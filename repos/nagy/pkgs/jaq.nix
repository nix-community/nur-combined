{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "jaq";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "01mf02";
    repo = "jaq";
    rev = "v${version}";
    hash = "sha256-lVpNe93/rtEzoeFxlR+bC01SHpHKxBb+fE2yQqUuE9o=";
  };

  cargoHash = "sha256-WLI/zZv9dciY9Nx9xqMUjkxzcXVw0tafxRejos8J5v8=";

  meta = with lib; {
    description = "Jq clone focused on correctness, speed and simplicity";
    homepage = "https://github.com/01mf02/jaq";
    license = with licenses; [ mit ];
  };
}
