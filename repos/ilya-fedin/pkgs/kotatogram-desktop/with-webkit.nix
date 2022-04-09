{ stdenv, lib, kotatogram-desktop, glib-networking, webkitgtk, wrapGAppsHook }:

stdenv.mkDerivation {
  pname = "${kotatogram-desktop.pname}-with-webkit";
  version = kotatogram-desktop.version;
  nativeBuildInputs = [ wrapGAppsHook ];
  buildInputs = [ glib-networking ];
  dontWrapGApps = true;
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out
    cp -r ${kotatogram-desktop}/share $out
  '';
  postFixup = ''
    mkdir -p $out/bin
    makeWrapper ${kotatogram-desktop}/bin/kotatogram-desktop $out/bin/kotatogram-desktop \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ webkitgtk ]}
  '';
  meta = kotatogram-desktop.meta;
}
