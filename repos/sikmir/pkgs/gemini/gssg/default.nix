{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "gssg";
  version = "2020-12-08";

  src = fetchFromSourcehut {
    owner = "~gsthnz";
    repo = pname;
    rev = "747b6b41fbe93f0b408a58c8e6a1f11c7945c819";
    sha256 = "131c9png0ky6sag39nr6jab2l62y88d0ii7cv6cq5ayj07gs7if8";
  };

  vendorSha256 = "188v7nax3yss7hqin41mjin8inkh6q7bv8pmbls2dwd809pxj5rp";

  meta = with lib; {
    description = "A gemini static site generator";
    homepage = "https://git.sr.ht/~gsthnz/gssg";
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
