{ lib, stdenv, buildGo117Module, fetchFromGitHub, fetchpatch }:

buildGo117Module rec {
  pname = "edgevpn";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-dH6x0tb73096ji5Eap0QQs6T7udyqRtWI0o0Zz107Ss=";
  };

  vendorSha256 = "sha256-ZhE8ckI1qVVFOycNm7lK0S8ygm8JZWIKYsXgccCfLp0=";

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
