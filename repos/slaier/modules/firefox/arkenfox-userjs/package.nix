{ lib, fetchurl }:
let
  owner = "arkenfox";
  repo = "user.js";
  version = "115.1";
in
fetchurl {
  pname = "${owner}-userjs";
  inherit version;

  url = "https://raw.githubusercontent.com/${owner}/${repo}/${version}/user.js";
  hash = "sha256-pyJviSywIuDtM+yKVYLNn+TXCKmVI7au83SUVeGaHXQ=";

  meta = with lib; {
    description = "Firefox privacy, security and anti-tracking: a comprehensive user.js template for configuration and hardening";
    homepage = "https://github.com/arkenfox/user.js";
    license = licenses.mit;
  };
}
