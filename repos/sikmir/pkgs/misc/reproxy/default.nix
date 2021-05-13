{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "reproxy";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "umputun";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-xZVMwa/44/hGmZxMbHGNInMjsO/5ZXalcHZq5xgO1No=";
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
