{
  paused = { stdenvNoCC, mpv-unwrapped, lib, fetchFromGitHub }: stdenvNoCC.mkDerivation rec {
    pname = "paused";
    version = "2021-05-29";

    src = fetchFromGitHub {
      owner = "kittywitch";
      repo = "mpvScripts";
      rev = "0a41713c8413494de6b2032a5806706699c79b01";
      sha256 = "0mdkdwpg8yafiwmra3qi3ni580fjvprdq7dkhklns1axdbr1p7c2";
    };

    dontBuild = true;
    dontUnpack = true;

    installPhase = ''
      install -Dm644 ${src}/paused.lua $out/share/mpv/scripts/paused.lua
    '';

    passthru.scriptName = "paused.lua";

    meta = {
      description = "Automatically hides and shows OSC based upon pause status";
    };
  };
  pause-indicator = { stdenvNoCC, fetchurl }: stdenvNoCC.mkDerivation rec {
    pname = "mpv-pause-indicator";
    version = "2018-04-28";
    src = fetchurl {
      url = "https://gist.githubusercontent.com/torque/9dbc69543118347d2e5f43239a7e609a/raw/bd9fcfe68a4f13b655c686e5790cbd2ee9489475/pause-indicator.lua";
      sha256 = "1x219m62iljxdsk18apaf1ccf4waqdwr9gilrfj64g4j6h7k1fak";
    };

    buildCommand = ''
      install -Dm644 $src $out/share/mpv/scripts/$scriptName
    '';

    scriptName = "pause-indicator.lua";
  };
}
