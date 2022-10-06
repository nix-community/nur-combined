{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "jj";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "aaronNGi";
    repo = "jj";
    rev = "v${version}";
    sha256 = "sha256-6MQY2amBa9NZKLwl5XdwWK3/mw5gkpv8hdykA9UQrgg=";
  };

  makeFlags = [
    "PREFIX=$(out)"
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  meta = with lib; {
    description = "An evolution of the suckless ii(1) file-based IRC client";
    inherit (src.meta) homepage;
    license = with licenses; [ mit ];
    mainProgram = "jjd";
  };
}
