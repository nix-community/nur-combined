{ lib
, buildGoModule
, fetchFromSourcehut
}:
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

  meta = with lib; {
    description = "Command to simulate input anywhere";
    homepage = "https://sr.ht/~geb/dotool/";
    license = licenses.gpl3;
  };
}
