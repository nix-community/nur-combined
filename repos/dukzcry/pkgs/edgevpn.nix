{ lib, stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "edgevpn";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "13mmaj68fbcgj4484bhca3d3jk4i249bj8xw01fjc4312y8q9j1x";
  };

  vendorSha256 = "1cdxnlcrfgxapwfpx5if2cdzxxrqkxbnlz95gl6aa2w7yx550jjr";

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
