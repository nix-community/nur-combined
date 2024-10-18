{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "thunderbird-gnome-theme";
  version = "115-unstable-2024-07-25";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "thunderbird-gnome-theme";
    rev = "628fcccb7788e3e0ad34f67114f563c87ac8c1dc";
    hash = "sha256-BHW9jlx92CsHY84FT0ce5Vxl0KFheLhNn2vndcIf7no=";
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
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
