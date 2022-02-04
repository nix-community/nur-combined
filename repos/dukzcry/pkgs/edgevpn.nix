{ lib, stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "edgevpn";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "0pbl5qwqsmbkkl4wy44xca8ap5kq7kkhlklmr76768gmyw03p9dm";
  };

  vendorSha256 = "0w39f3nx29aaxyd3z2c7vyfjilmj054h4vqspz8az4sldkq0jqbq";

  preBuild = ''
    substituteInPlace internal/version.go \
      --replace 'Version = ""' 'Version = "${src.rev}"'
  '';

  doCheck = false;

  meta = with lib; {
    description = "The immutable, decentralized, statically built VPN without any central server";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
