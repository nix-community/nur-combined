{
  lib,
  stdenv,
  temurin-jre-bin-21,
  xorg,
  alsa-lib,
  makeWrapper,
  ...
}:
let
  requiredLibraries = lib.makeLibraryPath [
    xorg.libXxf86vm
    alsa-lib
  ];
in
stdenv.mkDerivation {
  pname = "sklauncher";
  version = "3.2.10";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    temurin-jre-bin-21
    xorg.libXxf86vm
    alsa-lib
  ];

  installPhase = ''
    mkdir -p $out/{share,bin}
    install -Dm655 -t $out/share sklauncher.jar
    install -Dm755 -t $out/bin sklauncher
    wrapProgram $out/bin/sklauncher \
      --set SKLAUNCHER $out/share/sklauncher.jar \
      --set JAVA_HOME ${toString temurin-jre-bin-21} \
      --prefix LD_LIBRARY_PATH : ${requiredLibraries}
  '';

  meta = with lib; {
    licenses = licenses.unfree;
    description = "Secure and modern Minecraft Launcher";
    homepage = "https://skmedix.pl";
    maintainers = [ ];
    platforms = platforms.all;
  };
}
