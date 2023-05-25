{ stdenv
, lib
, fetchFromGitHub
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "bibata-cursors-tokyonight";
  version = "unstable-2022-07-02";

  src = fetchFromGitHub {
    repo = "Bibata-Modern-TokyoNight";
    owner = "ataraxiasjel";
    rev = "1ffc434ea2bd7e5847e18ed456e034f320a467ac";
    hash = "sha256-PREfEgv+FQZjYAQijY3bHQ/0E/L8HgJUBWeA0vdBkAA=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/icons"
    cp -r $src/Bibata-Modern-TokyoNight $out/share/icons

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = with lib; {
    description = "Bibata cursor for TokyoNight theme";
    homepage = "https://github.com/AtaraxiaSjel/Bibata-Modern-TokyoNight";
    license = licenses.unlicense;
    platforms = platforms.all;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
