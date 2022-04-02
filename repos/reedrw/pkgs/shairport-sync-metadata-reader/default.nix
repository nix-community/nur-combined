{ stdenv, lib, fetchFromGitHub, autoreconfHook }:

stdenv.mkDerivation rec {
  name = "shairport-sync-metadata-reader";

  src = fetchFromGitHub (lib.importJSON ./source.json);

  nativeBuildInputs = [ autoreconfHook ];

  #installPhase = ''
  #  install -D -m644 lemon.bdf "$out/share/fonts/lemon.bdf"
  #  install -D -m644 spectrum-fonts/berry.bdf "$out/share/fonts/berry.bdf"
  #'';

  meta = {
    description = "Sample Shairport Sync Metadata Player";
    homepage = "https://github.com/mikebrady/shairport-sync-metadata-reader";
    license = lib.licenses.mit;
  };

}
