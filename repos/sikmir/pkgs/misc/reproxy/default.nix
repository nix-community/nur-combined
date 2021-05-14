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

  postPatch = ''
    # Requires network access
    substituteInPlace app/main_test.go \
      --replace "Test_Main" "Skip_Main"
  '';

  vendorSha256 = null;

  postInstall = ''
    mv $out/bin/{app,reproxy}
  '';

  meta = with lib; {
    description = "Simple edge server / reverse proxy";
    homepage = "http://reproxy.io/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
