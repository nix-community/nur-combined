{
  lib,
  stdenv,
  fetchhg,
  autoreconfHook,
  pkg-config,
  python3,
  makeWrapper,
  guile,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wisp";
  version = "1.0.11";

  src = fetchhg {
    url = "https://hg.sr.ht/~arnebab/wisp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-J2heXIJhef2egrBUawp65r8VGkhh7lmEnzyqAEDpXPA=";
  };

  nativeBuildInputs = [
    autoreconfHook
    guile
    pkg-config
    python3
    makeWrapper
  ];

  buildInputs = [ guile ];

  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];

  postPatch = ''
    patchShebangs bootstrap.sh bootstrap-reader.sh
  '';

  postFixup = ''
    wrapProgram $out/bin/wisp \
      --set GUILE ${lib.getExe guile} \
      --prefix GUILE_LOAD_PATH : "$out/${guile.siteDir}:$GUILE_LOAD_PATH" \
      --prefix GUILE_LOAD_COMPILED_PATH : "$out/${guile.siteCcacheDir}:$GUILE_LOAD_COMPILED_PATH"
  '';

  meta = {
    mainProgram = "wisp";
    description = "Wisp turns indentation based syntax into Lisp";
    homepage = "https://www.draketo.de/software/wisp";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
