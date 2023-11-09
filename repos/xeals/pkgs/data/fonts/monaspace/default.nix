{ lib
, stdenvNoCC
, fetchFromGitHub
}:

let
  mkMonaspace =
    { pname
    , variants ? [ ]
    }: stdenvNoCC.mkDerivation rec {
      inherit pname;
      version = "1.000";

      src = fetchFromGitHub {
        owner = "githubnext";
        repo = "monaspace";
        rev = "v${version}";
        hash = "sha256-Zo56r0QoLwxwGQtcWP5cDlasx000G9BFeGINvvwEpQs=";
      };

      _variants = map (builtins.replaceStrings [ " " ] [ "" ]) variants;

      installPhase = ''
        local out_font=$out/share/fonts/monaspace
      '' + (if variants == [ ] then ''
        install -m444 -Dt $out_font fonts/otf/*.otf
        install -m444 -Dt $out_font fonts/variable/*.ttf
      '' else ''
        for variant in $_variants; do
          install -m444 -Dt $out_font fonts/otf/"$variant"-*.otf
          install -m444 -Dt $out_font fonts/variable/"$variant"Var*.ttf
        done
      '');

      meta = {
        description = "An innovative superfamily of fonts for code";
        homepage = "https://monaspace.githubnext.com/";
        longDescription = ''
          Since the earliest days of the teletype machine, code has been set in
          monospaced type — letters, on a grid. Monaspace is a new type system
          that advances the state of the art for the display of code on screen.
        '';
        license = lib.licenses.ofl;
        platforms = lib.platforms.all;
      };
    };
in
{
  monaspace = mkMonaspace {
    pname = "monaspace";
  };

  monaspace-argon = mkMonaspace {
    pname = "monaspace-argon";
    variants = [ "Monaspace Argon" ];
  };
  monaspace-krypton = mkMonaspace {
    pname = "monaspace-krypton";
    variants = [ "Monaspace Krypton" ];
  };
  monaspace-neon = mkMonaspace {
    pname = "monaspace-neon";
    variants = [ "Monaspace Neon" ];
  };
  monaspace-radon = mkMonaspace {
    pname = "monaspace-radon";
    variants = [ "Monaspace Radon" ];
  };
  monaspace-xenon = mkMonaspace {
    pname = "monaspace-xenon";
    variants = [ "Monaspace Xenon" ];
  };
}
