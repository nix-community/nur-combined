{ buildGoModule
, fetchFromGitHub
, lib
, nix-update-script
, olm
}:

buildGoModule rec {
  pname = "matrix-qq";
  version = "0.1.3";
  src = fetchFromGitHub {
    owner = "duo";
    repo = "matrix-qq";
    rev = version;
    sha256 = "sha256-ym3mrrgArIyX7hishymOMwvBoVNvXQAxwIGQivefj2I=";
  };

  vendorSha256 = "sha256-OOEPKo8ReHHVG+83Wrs2+I1Hv+bCI8oaEqRCD+YYLEQ=";

  buildInputs = [
    olm
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = pname; };
  };

  meta = with lib; {
    description = "A Matrix-QQ puppeting bridge";
    homepage = "https://github.com/duo/matrix-qq";
    license = licenses.agpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
