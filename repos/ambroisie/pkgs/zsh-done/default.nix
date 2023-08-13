{ lib, fetchFromGitHub, stdenvNoCC }:

stdenvNoCC.mkDerivation rec {
  pname = "zsh-done";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ambroisie";
    repo = "zsh-done";
    rev = "v${version}";
    hash = "sha256-DC7urJDXPP9vBYABrJF5KZ4HfMbrpHIVogSmEB8PWLA=";
  };

  dontConfigure = true;

  dontBuild = true;

  installPhase = ''
    plugindir="$out/share/zsh/site-functions"

    mkdir -p $plugindir
    cp $src/done.plugin.zsh $plugindir/
  '';

  meta = with lib; {
    description = ''
      A zsh plug-in to receive notifications when long processes finish
    '';
    homepage = "https://gitea.belanyi.fr/ambroisie/zsh-done";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ ambroisie ];
  };
}
