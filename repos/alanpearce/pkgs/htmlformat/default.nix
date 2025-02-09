{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule {
  pname = "htmlformat";
  version = "unstable-2025-02-09";

  src = fetchFromGitHub {
    owner = "a-h";
    repo = "htmlformat";
    rev = "c2a3d62ad1fc4d576b0534b17156ac02e0fc3139";
    sha256 = "0y9jq3d8s3g12lrjianm4crb2ny3ankgl72gd8vx7kfr3cs30rhq";
    # date = "2025-02-09T13:26:43Z";
  };

  vendorHash = "sha256-mJ6O8y/qg6GkiKZioOov8w4KcpIxG8KdA9PPeRvA/I0=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Htmlformat";
    homepage = "https://github.com/a-h/htmlformat";
    license = licenses.mit;
    maintainers = with maintainers; [ alanpearce ];
    mainProgram = "htmlformat";
  };
}
