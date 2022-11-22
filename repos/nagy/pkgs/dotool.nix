{ lib, fetchFromSourcehut, buildGoModule }:

buildGoModule rec {
  pname = "dotool";
  version = "1.0";

  src = fetchFromSourcehut {
    owner = "~geb";
    repo = pname;
    rev = version;
    sha256 = "sha256-NFCcBAan9D9WRsnkQwfbK9Z1PCicIrxOpJMqaVfOaUQ=";
  };

  vendorSha256 = "sha256-t3b1clfAkU6lsL4gLhYIaXSRfFdK3pLULihp0o5T/sk=";

  meta = with lib; {
    description = "Command to simulate input anywhere";
    inherit (src.meta) homepage;
    license = with licenses; [ gpl3Only ];
  };
}
