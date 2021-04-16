{ lib, rustPlatform, sources }:

rustPlatform.buildRustPackage {
  pname = "xtr-unstable";
  version = lib.substring 0 10 sources.xtr.date;

  src = sources.xtr;

  cargoPatches = [ ./cargo-lock.patch ];
  cargoSha256 = "0l7gj8ddhjvbnzkvm9ij2f6p89zp2faiqm03ra26a75589imnw9m";

  meta = with lib; {
    inherit (sources.xtr) description homepage;
    license = with licenses; [ agpl3 mit ];
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
