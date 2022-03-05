{ lib, fetchCrate, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "pepper";
  version = "0.23.3";

  src = fetchCrate {
    inherit pname version;
    sha256 = "1wvl28c6vgc782rb77535sbds6a9wdjhz3kbrpm81mlbasxicyy5";
  };

  cargoSha256 = "19fnjzflbj17l3gh0i5ib71jbf6s57p28npjb4nv0f458q907mwj";

  meta = with lib; {
    description = "A simple and opinionated modal code editor for your terminal";
    homepage = "https://vamolessa.github.io/pepper/";
    license = licenses.gpl3Plus;
  };
}
