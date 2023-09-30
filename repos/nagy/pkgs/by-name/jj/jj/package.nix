{ lib, stdenv, fetchFromGitHub, gawk }:

stdenv.mkDerivation rec {
  pname = "jj";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "aaronNGi";
    repo = "jj";
    rev = "v${version}";
    hash = "sha256-6MQY2amBa9NZKLwl5XdwWK3/mw5gkpv8hdykA9UQrgg=";
  };

  makeFlags = [ "PREFIX=$(out)" "CC:=$(CC)" ];

  buildInputs = [ gawk ]; # to patch shebangs

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "An evolution of the suckless ii(1) file-based IRC client";
    license = licenses.mit;
    mainProgram = "jjd";
  };
}
