{ lib, buildGoModule, fetchgit }:

buildGoModule {
  pname = "kineto";
  version = "2021-01-15";

  src = fetchgit {
    url = "https://git.sr.ht/~sircmpwn/kineto";
    rev = "8f35e0a2b17b70691b8634c2bd8c99f98557105c";
    sha256 = "0vh28k3mnqv27nr3s6c4b4zcf5q1q2c1fs73np1cb0l4fpl6l7s2";
  };

  vendorSha256 = "06yjz1rsnfz2dyky53q4y5g05f2h724cjvc9z5d57rra1kjp3p1j";

  meta = with lib; {
    description = "An HTTP to Gemini proxy";
    homepage = "https://git.sr.ht/~sircmpwn/kineto";
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
