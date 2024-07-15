{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "thunderbird-gnome-theme";
  version = "115-unstable-2024-07-15";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "thunderbird-gnome-theme";
    rev = "e9ba48261ea8cea425e47586e33dd15167a77e74";
    hash = "sha256-kIUyPOTefaMvdwCu6/IBaaVkWWlD5+nfD78BkN+XEWA=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/
    cp -r $src/* $out/

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
