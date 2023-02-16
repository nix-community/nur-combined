{ lib
, stdenvNoCC
, fetchFromGitHub
, oscSupport ? false
}:

stdenvNoCC.mkDerivation rec {
  pname = "mpv-quality-menu";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "christoph-heinrich";
    repo = "mpv-quality-menu";
    rev = "v${version}";
    sha256 = "sha256-oLM7PN9tE0k1XhDgI7DvpeDhEtrghtxV3uN4jahdI3E=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/mpv/scripts
    cp quality-menu.lua $out/share/mpv/scripts
  '' + lib.optionalString oscSupport ''
    cp quality-menu-osc.lua $out/share/mpv/scripts
  '' + ''
    runHook postInstall
  '';

  passthru.scriptName = "quality-menu.lua";

  meta = with lib; {
    description = "A userscript for MPV that allows you to change youtube video quality (ytdl-format) on the fly";
    homepage = "https://github.com/christoph-heinrich/mpv-quality-menu";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ lunik1 ];
  };
}
