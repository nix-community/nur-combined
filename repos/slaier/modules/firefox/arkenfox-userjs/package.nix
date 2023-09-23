{ lib, fetchurl }:
let
  owner = "arkenfox";
  repo = "user.js";
  version = "117.0";
in
fetchurl {
  pname = "${owner}-userjs";
  inherit version;

  url = "https://raw.githubusercontent.com/${owner}/${repo}/${version}/user.js";
  hash = "sha256-1z73xMZMmYzk7qnbsNdgO2tdrVfLVFK4zB2DfG5kxLY=";

  meta = with lib; {
    description = "Firefox privacy, security and anti-tracking: a comprehensive user.js template for configuration and hardening";
    homepage = "https://github.com/arkenfox/user.js";
    license = licenses.mit;
  };
}
