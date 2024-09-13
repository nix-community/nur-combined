{
  stdenv,
  lib,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "bibata-cursors-tokyonight";
  version = "1.0";

  src = fetchFromGitHub {
    repo = "Bibata-Modern-TokyoNight";
    owner = "ataraxiasjel";
    rev = version;
    hash = "sha256-PREfEgv+FQZjYAQijY3bHQ/0E/L8HgJUBWeA0vdBkAA=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/icons"
    cp -r $src/Bibata-Modern-TokyoNight $out/share/icons

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Bibata cursor for TokyoNight theme";
    homepage = "https://github.com/AtaraxiaSjel/Bibata-Modern-TokyoNight";
    license = licenses.unlicense;
    platforms = platforms.all;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
