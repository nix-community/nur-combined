{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "thunderbird-gnome-theme";
  version = "115-unstable-2024-11-26";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "thunderbird-gnome-theme";
    rev = "1994e7ec0649053e2a0811973245758d41e33f5f";
    hash = "sha256-i0Uo5EN45rlGuR85hvPet43zW/thOQTwHypVg9shTHU=";
  };

  installPhase = ''
    runHook preInstall

    cp -r $src $out/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "A GNOME theme for Thunderbird";
    homepage = "https://github.com/rafaelmardojai/thunderbird-gnome-theme";
    license = lib.licenses.unlicense;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
