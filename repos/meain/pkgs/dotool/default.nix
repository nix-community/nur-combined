{ lib, fetchFromSourcehut, buildGoModule }:

buildGoModule rec {
  pname = "dotool";
  version = "90184107489abb7a440bf1f8df9b123acc8f9628";

  src = fetchFromSourcehut {
    owner = "~geb";
    repo = pname;
    rev = "90184107489abb7a440bf1f8df9b123acc8f9628";
    sha256 = "sha256-92nuWHOwF/6kjFb63NwyXc3wSNoHbo+9WDbmCajXLUI=";
  };

  vendorSha256 = "sha256-v0uoG9mNaemzhQAiG85RequGjkSllPd4UK2SrLjfm7A=";

  meta = with lib; {
    description = "Command to simulate input anywhere";
    inherit (src.meta) homepage;
    license = with licenses; [ gpl3Only ];
  };
}