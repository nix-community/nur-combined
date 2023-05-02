{ lib
, stdenv
, fetchFromSourcehut
, buildGoModule
}:

buildGoModule rec {
  pname = "wlhax";
  version = "2022-10-11";

  src = fetchFromSourcehut {
    owner = "~kennylevinsen";
    repo = pname;
    rev = "6ba773a62975e10a39b4881960cf177dd2c82faf";
    sha256 = "sha256-94Lxf5w+Kf6TAD7DFaMpWXWTprhiCAFeCyoUZa1e4y0=";
  };

  vendorSha256 = "sha256-1zAKVg+l1frdE+PYgc0sjjQ+v/OJa9b7leikPwbDl3o=";

  meta = with lib; {
    description = "Wayland proxy that monitors and displays various application state";
    homepage = "https://git.sr.ht/~kennylevinsen/wlhax";
    license = licenses.gpl3Plus;
  };
}

