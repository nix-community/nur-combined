{ lib, fetchurl }:
let
  owner = "arkenfox";
  repo = "user.js";
  version = "115.0";
in
fetchurl {
  pname = "${owner}-userjs";
  inherit version;

  url = "https://raw.githubusercontent.com/${owner}/${repo}/${version}/user.js";
  hash = "sha256-sysEtq4aEWmkKy3KPe+4J/HJxjCxNcTAzptZ7s5JrJg=";

  meta = with lib; {
    description = "Firefox privacy, security and anti-tracking: a comprehensive user.js template for configuration and hardening";
    homepage = "https://github.com/arkenfox/user.js";
    license = licenses.mit;
  };
}
