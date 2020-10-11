{ lib, rustPlatform, sources }:
let
  pname = "xtr";
  date = lib.substring 0 10 sources.xtr.date;
  version = "unstable-" + date;
in
rustPlatform.buildRustPackage {
  inherit pname version;
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
