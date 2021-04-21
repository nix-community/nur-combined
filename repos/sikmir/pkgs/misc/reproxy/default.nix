{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "reproxy";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "umputun";
    repo = pname;
    rev = "v${version}";
    sha256 = "1ai72c7yj9328ssj4hhklg7zrkpb1b0l315infbdzkchc82p7wwj";
  };

  vendorSha256 = null;

  doCheck = false;

  postInstall = "mv $out/bin/{app,reproxy}";

  meta = with lib; {
    description = "Simple edge server / reverse proxy";
    homepage = "http://reproxy.io/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
