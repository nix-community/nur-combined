{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "satellite";
  version = "1.0.0";

  src = fetchFromSourcehut {
    owner = "~gsthnz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-fOsgTuJb/UFmOKb7xV+pvqOhokEuOgt47IYDEpa0DWg=";
  };

  vendorSha256 = "188v7nax3yss7hqin41mjin8inkh6q7bv8pmbls2dwd809pxj5rp";

  meta = with lib; {
    description = "Small Gemini server for serving static files";
    inherit (src.meta) homepage;
    license = licenses.agpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
