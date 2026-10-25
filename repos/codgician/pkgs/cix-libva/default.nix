{
  lib,
  libva,
  fetchFromGitHub,
}:

libva.overrideAttrs (old: {
  pname = "cix-libva";
  version = "2.22.1-unstable-2026-07-20";

  src = fetchFromGitHub {
    owner = "cixtech";
    repo = "cix_libva";
    rev = "d2501e4747efc8b68b5809d3d05959178354a5d5";
    hash = "sha256-1fDZKR9QRq7o8qXEQ2SCvyBKD/jdzbBsPHZ+WnCG4YM=";
  };

  # libva's changelog points at intel/libva for this version, which does not exist.
  meta = removeAttrs old.meta [ "changelog" ] // {
    description = "CIX VA-API library with Sky1 multimedia extensions";
    homepage = "https://github.com/cixtech/cix_libva";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ codgician ];
    platforms = [ "aarch64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
