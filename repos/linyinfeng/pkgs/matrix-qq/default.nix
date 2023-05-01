{ buildGoModule
, go
, fetchFromGitHub
, lib
, nix-update-script
, olm
}:

buildGoModule rec {
  pname = "matrix-qq";
  version = "0.1.7";
  src = fetchFromGitHub {
    owner = "duo";
    repo = "matrix-qq";
    rev = version;
    sha256 = "sha256-Iio0aQ+C67CoTK7QLDrqAmrJ0cIr0tKayGAFw64jCws=";
  };

  vendorSha256 = "sha256-QwU3UodZi6cntHy3VcGJ4kXf0rCJqxzWFJEVknalZR0=";

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
