{
  lib,
  stdenv,
  fetchzip,
  pkg-config,
  makeWrapper,
  guile,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wisp";
  version = "1.0.12";

  src = fetchzip {
    url = "https://www.draketo.de/software/wisp-${finalAttrs.version}.tar.gz";
    hash = "sha256-LUHsOHhxZ9Qs2v3miuVwppnHcXBV5Gloa5s5nTevaIc=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [ guile ];

  postPatch = ''
    patchShebangs bootstrap-reader.sh
  '';

  postFixup = ''
    wrapProgram $out/bin/wisp \
      --set GUILE ${lib.getExe' guile "guile"} \
      --prefix GUILE_LOAD_PATH : "$out/${guile.siteDir}:$GUILE_LOAD_PATH" \
      --prefix GUILE_LOAD_COMPILED_PATH : "$out/${guile.siteCcacheDir}:$GUILE_LOAD_COMPILED_PATH"
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];

  doInstallCheck = true;
  dontVersionCheck = true;

  meta = {
    mainProgram = "wisp";
    description = "Wisp turns indentation based syntax into Lisp";
    homepage = "https://www.draketo.de/software/wisp";
    license = lib.licenses.gpl3Plus;
    inherit (guile.meta) platforms;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
