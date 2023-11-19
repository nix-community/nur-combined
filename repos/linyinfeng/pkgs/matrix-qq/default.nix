{ buildGoModule
, go
, fetchFromGitHub
, lib
, nix-update-script
, olm
}:

buildGoModule rec {
  pname = "matrix-qq";
  version = "0.1.9";
  src = fetchFromGitHub {
    owner = "duo";
    repo = "matrix-qq";
    rev = version;
    sha256 = "sha256-A35i4C0qmYSw02O/RD/RzJ3FsVDjjcAhOjaqfk8fVys=";
  };

  vendorHash = "sha256-Haz08hkKNOilX2uBum+en9z97927kobj49bsLXow/Yo=";

  buildInputs = [
    olm
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Tag=${version}"
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
    broken = !(lib.versionAtLeast go.version "1.20");
  };
}
