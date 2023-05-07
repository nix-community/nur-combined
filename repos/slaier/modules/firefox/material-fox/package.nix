{ lib, stdenvNoCC, fetchFromGitHub }:
let
  version = "93.1";
in
stdenvNoCC.mkDerivation {
  pname = "material-fox";
  inherit version;

  src = fetchFromGitHub ({
    owner = "muckSponge";
    repo = "MaterialFox";
    rev = "v${version}";
    sha256 = "sha256-M20PD3RvkOqZGv4+SzSMGkKdmJ4ZVEDH7WHB4QKFlRw=";
  });

  installPhase = ''
    mkdir -p $out
    cp ./user.js $out/user.js
    cp -r ./chrome $out/chrome
  '';

  meta = with lib; {
    description = "A Material Design-inspired userChrome.css theme for Firefox.";
    homepage = "https://github.com/muckSponge/MaterialFox";
    license = licenses.mit;
  };
}
