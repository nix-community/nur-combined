{ lib, fetchFromSourcehut, buildGoModule }:

buildGoModule rec {
  pname = "dotool";
  version = "1.2";

  src = fetchFromSourcehut {
    owner = "~geb";
    repo = pname;
    rev = version;
    hash = "sha256-HWJo9cYOkAXZtqrAUKM4o9Ix46KH9HCbB4eiWnky1x4=";
  };

  vendorHash = "sha256-v0uoG9mNaemzhQAiG85RequGjkSllPd4UK2SrLjfm7A=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "Command to simulate input anywhere";
    license = licenses.gpl3Only;
    changelog = "https://git.sr.ht/~geb/dotool/tree/${version}/item/CHANGELOG.md";
  };
}
