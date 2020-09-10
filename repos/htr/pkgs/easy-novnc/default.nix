{ buildGoModule
, fetchFromGitHub
, lib
}:

buildGoModule rec {
  pname = "easy-novnc";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "pgaskin";
    repo = "easy-novnc";
    rev = "v${version}";
    sha256 = "0y7ia3z6mv4wr1jqnhd4pnw2zdwr5r5prm3ybffnx8y1hr2x13m2";
  };

  vendorSha256 = "06jdjjymva4pv75kc4yzgldvfgkb67d6jj8xapwca3z33gmvc7pb";

  doCheck = false;

  meta = with lib; {
    description = "An easy way to run a noVNC instance and proxy with a single binary";
    homepage = "https://github.com/pgaskin/easy-novnc";
    license = licenses.mit;
    maintainers = with maintainers; [ htr ];
  };
}
