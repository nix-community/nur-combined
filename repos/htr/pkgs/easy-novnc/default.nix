{ buildGoModule
, fetchFromGitHub
, lib
, sources
}:

buildGoModule rec {
  pname = "easy-novnc";
  version = "1.1.0";

  src = sources.easy-novnc;

  vendorSha256 = "06jdjjymva4pv75kc4yzgldvfgkb67d6jj8xapwca3z33gmvc7pb";

  doCheck = false;

  meta = with lib; {
    description = "An easy way to run a noVNC instance and proxy with a single binary";
    homepage = "https://github.com/pgaskin/easy-novnc";
    license = licenses.mit;
    maintainers = with maintainers; [ htr ];
    broken = true;
  };
}
