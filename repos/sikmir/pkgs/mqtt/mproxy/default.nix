{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

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

  meta = {
    description = "MQTT proxy";
    homepage = "https://github.com/mainflux/mproxy";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
