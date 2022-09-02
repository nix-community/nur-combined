{ lib, fetchFromGitHub, buildGoModule, go-bindata }:

buildGoModule rec {
  pname = "glauth";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "glauth";
    repo = "glauth";
    rev = "v${version}";
    hash = "sha256-2U9LmK+gqVaYnVBvqS3CeNmrK2pFmS5X/oQqFb4MQKk=";
  };

  vendorSha256 = "sha256-iYQi3k9uIsbmf4tTAruiowH0gN+WqvRTYIfzmjSoNqI=";

  nativeBuildInputs = [ go-bindata ];

  ldflags = [
    "-s -w"
    "-X main.LastGitTag=v${version}"
    "-X main.GitTagIsCommit=1"
  ];

  preBuild = "go-bindata -pkg=assets -o=pkg/assets/bindata.go assets";

  doCheck = false;

  meta = with lib; {
    description = "A lightweight LDAP server for development, home use, or CI";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
