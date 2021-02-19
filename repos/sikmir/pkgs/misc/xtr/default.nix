{ lib, rustPlatform, sources }:

rustPlatform.buildRustPackage {
  pname = "xtr-unstable";
  version = lib.substring 0 10 sources.xtr.date;

  src = sources.xtr;

  cargoPatches = [ ./cargo-lock.patch ];
  cargoSha256 = "1pyidpfk18j50bkrhj8xk4k03h80w2q0l1f0yfkpwss2nfdvpp9x";

  meta = with lib; {
    inherit (sources.xtr) description homepage;
    license = with licenses; [ agpl3 mit ];
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
