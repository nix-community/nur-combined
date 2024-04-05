{ lib, stdenvNoCC, fetchFromGitLab, makeWrapper, wallutils }:

stdenvNoCC.mkDerivation rec {
  pname = "sunpaper";
  version = "2024-04-05";

  src = fetchFromGitLab {
    owner = "repos-holder";
    repo = "sunpaper";
    rev = "81e4dfc94d753d05c70bc30bcfd6ad81b6cbbaa2";
    hash = "sha256-p1jPRUwxRgqQ/irSMqAyIOzdku05gt/OrlevGUxwMjE=";
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
      --prefix PATH : ${lib.makeBinPath [ wallutils ]}
  '';

  meta = {
    description = "A utility to change wallpaper based on local weather, sunrise and sunset times";
    homepage = src.meta.homepage;
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
}