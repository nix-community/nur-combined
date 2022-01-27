{ lib, stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "edgevpn";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "11y11liad6wwxdlkiszihrh0z7n9j07br20kxsf0gxp00864q0pz";
  };

  vendorSha256 = "0hc810ykhanaipl6gx2dqsdmikg1h71jpz5wzl7hb5fsqcw787dx";

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
