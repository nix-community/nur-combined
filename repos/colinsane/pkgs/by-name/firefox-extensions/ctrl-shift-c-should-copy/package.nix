{
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  unstableGitUpdater,
  wrapFirefoxAddonsHook,
  zip,
}:

stdenvNoCC.mkDerivation {
  pname = "ctrl-shift-c-should-copy";
  version = "0-unstable-2023-03-03";

  src = fetchFromGitHub {
    owner = "jscher2000";
    repo = "Ctrl-Shift-C-Should-Copy";
    rev = "d9e67f330d0e13fc3796e9d797f12450f75a8c6a";
    hash = "sha256-8v/b8nft7WmPOKwOR27DPG/Z9rAEPKBP4YODM+Wg8Rk=";
  };

  nativeBuildInputs = [
    wrapFirefoxAddonsHook
    zip
  ];

  buildPhase = ''
    runHook preBuild
    zip -r extension.zip ./*
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir $out
    install extension.zip $out/$extid.xpi
    runHook postInstall
  '';

  extid = "ctrl-shift-c-copy@jeffersonscher.com";

  passthru = {
    updateScript = unstableGitUpdater { };
  };

  meta = {
    homepage = "https://github.com/jscher2000/Ctrl-Shift-C-Should-Copy";
    description = "Potential Firefox extension to intercept Ctrl+Shift+C, block opening developer tools, and copy the selection to the clipboard.";
    longDescription = ''
      it comes with several limitations:
      - doesn't work on new-tab page
      - doesn't work if the focus isn't on page content
        - e.g. ctrl+shift+c from URL bar still brings up dev console, incorrectly.

      the proper fix to disabling Ctrl+Shift+C seems to require compiling Firefox from source, as of their Quantum project post-2019.
    '';
    maintainer = with lib.maintainers; [ colinsane ];
  };
}
