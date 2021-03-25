{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "satellite";
  version = "1.0.0";

  src = fetchFromSourcehut {
    owner = "~gsthnz";
    repo = pname;
    rev = "v${version}";
    sha256 = "0s0dnjb140w6xiw0nfif86ia38xym5gwbyx671k43zavw9721svw";
  };

  vendorSha256 = "188v7nax3yss7hqin41mjin8inkh6q7bv8pmbls2dwd809pxj5rp";

  meta = with lib; {
    description = "Small Gemini server for serving static files";
    homepage = "https://git.sr.ht/~gsthnz/satellite";
    license = licenses.agpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
