{ config, lib, pkgs, ... }:

with pkgs;

let
  src = fetchFromGitHub {
    owner = "fastenhealth";
    repo = "fasten-onprem";
    rev = "v${version}";
    hash = "sha256-I/JZFxFNXJvo/s/bLg66iSmgEaU3XmfQhZzwlXEotHY=";
  };
in
{
  backend = buildGoModule rec {
    pname = "fastenhealth";
    version = "0.0.12";


    vendorHash = "sha256-fFIaP4mRmD5mh+cHV4FfJrskhh9kkHxBqCTUWrU8owE=";

    meta = with lib; {
      description = "Simple command-line snippet manager, written in Go";
      homepage = "https://github.com/knqyf263/pet";
      license = licenses.mit;
      maintainers = with maintainers; [ ProducerMatt ];
      broken = true;
    };
  };
  frontend = buildYarnPackage {
    postBuild = ''
    mkdir -p $out/lib/frontend
    cp -r $src/frontend $out/lib/frontend
  '';
  };
}
