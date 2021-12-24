{ lib, clangStdenv, fetchgit, tup }:

let
  pname = "speedtime";
  url = "https://gitdab.com/elle/${pname}";
in clangStdenv.mkDerivation rec {
  inherit pname;
  version = "2021.12.23";

  src = fetchgit {
    inherit url;
    rev = version;
    sha256 = "1zjgg4vdk2xax1v3sj775cndai5m6lfmly5bp3bi0lwwf90sycwb";
  };

  nativeBuildInputs = [ tup ];

  installPhase = ''
    runHook preInstall
    mkdir -p \
      $out/bin \
      $out/share/man/man1 \
      $out/share/applications \
      $out/share/icons/hicolor/scalable/apps
    cp ./speedtime $out/bin/
    cp ./extras/speedtime.1 $out/share/man/man1/
    cp ./extras/speedtime.desktop $out/share/applications/
    cp ./extras/speedtime.svg $out/share/icons/hicolor/scalable/apps/
    runHook postInstall
  '';

  meta = with lib; {
    description = "A timer.";
    longDescription =
      "Speedtime is a timer that runs entirely within a terminal.";
    homepage = url;
    license = licenses.free;
    platforms = platforms.linux;
  };
}
