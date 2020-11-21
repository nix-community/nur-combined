{ lib, rustPlatform, sources }:

rustPlatform.buildRustPackage {
  pname = "xtr-unstable";
  version = lib.substring 0 10 sources.xtr.date;

  src = sources.xtr;

  cargoPatches = [ ./cargo-lock.patch ];
  cargoSha256 = "1s1w8kdc9wjzvr975vdcrxwj3fvhfksb7ij5rnchz4c4pyzl3xmc";

  meta = with lib; {
    inherit (sources.xtr) description homepage;
    license = with licenses; [ agpl3 mit ];
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
