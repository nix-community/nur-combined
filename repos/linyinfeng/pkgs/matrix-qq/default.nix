{ buildGo120Module
, go
, fetchFromGitHub
, lib
, nix-update-script
, olm
}:

# TODO use buildGoModule instread after 1.20
assert !(lib.versionAtLeast go.version "1.20");

buildGo120Module rec {
  pname = "matrix-qq";
  version = "0.1.5";
  src = fetchFromGitHub {
    owner = "duo";
    repo = "matrix-qq";
    rev = version;
    sha256 = "sha256-gdAWzOVuFvpEMvZWJfgj+oQKGH3MP8n3U/RNJA1nwOk=";
  };

  vendorSha256 = "sha256-KZxotp42lKw7hty5OMEspQBurfQjZ9Bj93FP7sS/aSQ=";

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
  };
}
