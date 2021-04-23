{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "kineto";
  version = "2021-01-15";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "8f35e0a2b17b70691b8634c2bd8c99f98557105c";
    hash = "sha256-Qh9q6HWEgsXCteNoF5jAARfHPlmEGT2yPWJjW8dEAm4=";
  };

  vendorSha256 = "06yjz1rsnfz2dyky53q4y5g05f2h724cjvc9z5d57rra1kjp3p1j";

  meta = with lib; {
    description = "An HTTP to Gemini proxy";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
