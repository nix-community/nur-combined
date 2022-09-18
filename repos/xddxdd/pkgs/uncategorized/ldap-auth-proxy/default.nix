{ lib
, fetchFromGitHub
, buildGoPackage
, ...
}:

buildGoPackage rec {
  pname = "ldap-auth-proxy";
  version = "66a8236";
  src = fetchFromGitHub {
    owner = "pinepain";
    repo = pname;
    rev = "66a8236af574f554478fe376051b95f61235efc9";
    sha256 = "sha256-kV3P3hRmfFH5g+BzjxZGstVHoQ4KMn9DVup5cInin+Y=";
  };

  goPackagePath = "github.com/pinepain/ldap-auth-proxy";
  goDeps = ./deps.nix;

  meta = with lib; {
    description = "A simple drop-in HTTP proxy for transparent LDAP authentication which is also a HTTP auth backend.";
    homepage = "https://github.com/pinepain/ldap-auth-proxy";
    license = licenses.mit;
  };
}
