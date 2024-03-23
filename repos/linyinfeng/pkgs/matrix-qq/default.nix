{
  buildGoModule,
  go,
  fetchFromGitHub,
  lib,
  nix-update-script,
  olm,
}:

buildGoModule rec {
  pname = "matrix-qq";
  version = "0.1.11";
  src = fetchFromGitHub {
    owner = "duo";
    repo = "matrix-qq";
    rev = version;
    sha256 = "sha256-8QY5rySBJ+FSH8uEHewFX7WqhpbzZL1+fMEduDPHu9U=";
  };

  vendorHash = "sha256-VLlW178B1a2mEwEb/aLZFYPVdC9hzQzI1gen+M8pg1I=";

  buildInputs = [ olm ];

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
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ yinfeng ];
    broken = !(lib.versionAtLeast go.version "1.20");
  };
}
