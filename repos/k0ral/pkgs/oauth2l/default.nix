{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "oauth2l";
  version = "1.3.0";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "google";
    repo = pname;
    sha256 = "bL1bys/CBo/P9VfWc/FB8JHW/aBwC521V8DB1sFBIAA=";
  };

  vendorSha256 = null;

  doCheck = false;

  meta = with lib; {
    description = "Simple CLI for interacting with Google API authentication";
    homepage = "https://github.com/google/${pname}";
    license = licenses.mit;
    maintainers = with maintainers; [ koral ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
