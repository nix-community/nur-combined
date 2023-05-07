{ lib, fetchurl }:
let
  owner = "arkenfox";
  repo = "user.js";
  version = "112.0";
in
fetchurl {
  pname = "${owner}-userjs";
  inherit version;

  url = "https://raw.githubusercontent.com/${owner}/${repo}/${version}/user.js";
  hash = "sha256-ZJ3HyM00hG3aVpOnrcjc/D75WsRj6rpKVRmmC3vp/4k=";

  meta = with lib; {
    description = "Firefox privacy, security and anti-tracking: a comprehensive user.js template for configuration and hardening";
    homepage = "https://github.com/arkenfox/user.js";
    license = licenses.mit;
  };
}
