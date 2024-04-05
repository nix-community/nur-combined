{ lib, stdenvNoCC, fetchFromGitLab, makeWrapper, wallutils, swww, pywal, wget, bc }:

stdenvNoCC.mkDerivation rec {
  pname = "sunpaper";
  version = "2024-04-05";

  src = fetchFromGitLab {
    owner = "repos-holder";
    repo = "sunpaper";
    rev = "b335b721c415edde246c4838e8e193bbc7357d1c";
    hash = "sha256-8ItNc71wtzXfdMIse3A55h0gJs29YYyzPGbGWnuuHXA=";
  };

  buildInputs = [ makeWrapper ];

  postPatch = ''
    substituteInPlace sunpaper.sh \
      --replace '$HOME/sunpaper/images/' "/run/current-system/sw/share/sunpaper/images/"
  '';

  installPhase = ''
    install -Dm555 sunpaper.sh $out/bin/sunpaper.sh
    mkdir -p "$out/share/sunpaper/images"
    cp -R images $out/share/sunpaper/
    wrapProgram $out/bin/sunpaper.sh \
      --prefix PATH : ${lib.makeBinPath [ wallutils swww pywal wget bc ]}
  '';

  meta = {
    description = "A utility to change wallpaper based on local weather, sunrise and sunset times";
    homepage = src.meta.homepage;
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
}