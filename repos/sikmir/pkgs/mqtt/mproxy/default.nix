{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "mproxy";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "mainflux";
    repo = "mproxy";
    rev = "v${version}";
    hash = "sha256-gjFAuYDOFslhfDN+uWY3RZroUDrMERvBGi+gTtl4eLo=";
  };

  vendorHash = null;

  postInstall = ''
    mv $out/bin/{cmd,mproxy}
    mv $out/bin/{client,mproxy-client}
  '';

  meta = with lib; {
    description = "MQTT proxy";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
