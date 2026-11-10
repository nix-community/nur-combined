{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot-cbz.yazi";
  version = "0-unstable-2026-11-10";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "acdbca5fe4b371490de3d6080aebcd101240e856";
    hash = "sha256-sAffV0lOvxD2zzi839KY7ghiWt91TuGw2hp9jYZwddQ=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    # keep-sorted start
    description = "comic books that have ComicInfo.xml";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/spot-cbz.yazi";
    license = lib.licenses.gpl3Only;
    # keep-sorted end
  };
}
