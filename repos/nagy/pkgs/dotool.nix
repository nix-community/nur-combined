{ lib, fetchFromSourcehut, buildGoModule }:

buildGoModule rec {
  pname = "dotool";
  version = "1.2";

  src = fetchFromSourcehut {
    owner = "~geb";
    repo = pname;
    rev = version;
    sha256 = "sha256-HWJo9cYOkAXZtqrAUKM4o9Ix46KH9HCbB4eiWnky1x4=";
  };

  vendorSha256 = "sha256-v0uoG9mNaemzhQAiG85RequGjkSllPd4UK2SrLjfm7A=";

  meta = with lib; {
    description = "Command to simulate input anywhere";
    inherit (src.meta) homepage;
    license = with licenses; [ gpl3Only ];
    changelog = "https://git.sr.ht/~geb/dotool/tree/${version}/item/CHANGELOG.md";
  };
}
