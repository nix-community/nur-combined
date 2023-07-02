{ lib, fetchFromSourcehut, buildGoModule, pkg-config, libxkbcommon }:

buildGoModule rec {
  pname = "dotool";
  version = "1.3";

  src = fetchFromSourcehut {
    owner = "~geb";
    repo = pname;
    rev = version;
    hash = "sha256-z0fQ+qenHjtoriYSD2sOjEvfLVtZcMJbvnjKZFRSsMA=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libxkbcommon ];

  vendorHash = "sha256-v0uoG9mNaemzhQAiG85RequGjkSllPd4UK2SrLjfm7A=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "Command to simulate input anywhere";
    license = licenses.gpl3Only;
    changelog = "https://git.sr.ht/~geb/dotool/tree/${version}/item/CHANGELOG.md";
  };
}
