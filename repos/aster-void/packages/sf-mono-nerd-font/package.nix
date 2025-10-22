# https://github.com/epk/SF-Mono-Nerd-Font
# Source License: None
{
  stdenvNoCC,
  lib,
}:
stdenvNoCC.mkDerivation {
  pname = "sf-mono-nerd-font";
  version = "v18.0d1e1";

  src = builtins.fetchTarball {
    url = "https://github.com/epk/SF-Mono-Nerd-Font/archive/refs/tags/v18.0d1e1.0.tar.gz";
    sha256 = "0i2wzyywbi7pjb49gjbrpi3av3hplkwd7brahi61flw26aykz43z";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/opentype
    cp *.otf $out/share/fonts/opentype/

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/epk/SF-Mono-Nerd-Font";
    description = "Apple's SF Mono font patched with the Nerd Fonts patcher ";
    maintainers = [];
    platforms = platforms.all;
  };
}
