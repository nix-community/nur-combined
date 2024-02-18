{ lib
, stdenv
, unzip
, fetchurl
}:

let
  glowsans = { pname, version, sha256, lang }: stdenv.mkDerivation
    rec{

      inherit pname version sha256;
      src = fetchurl {
        url = "https://github.com/welai/glow-sans/releases/download/v${version}/GlowSans${lang}-Normal-v${version}.zip";
        inherit sha256;
      };


      # Work around the "unpacker appears to have produced no directories"
      # case that happens when the archive doesn't have a subdirectory.
      setSourceRoot = "sourceRoot=`pwd`";
      nativeBuildInputs = [ unzip ];
      installPhase = ''
        find . -name '*.otf'    -exec install -Dt $out/share/fonts/opentype {} \;
      '';

      meta = with lib; {
        homepage = "https://github.com/welai/glow-sans";
        description = ''
          SHSans-derived CJK font family with a more concise & modern look
        '';
        license = with licenses;[ mit ofl ];
        platforms = platforms.all;
        maintainers = with maintainers; [ oluceps ];
      };

    };
in
{
  glowsansJ = glowsans {
    pname = "glowsans-J";
    version = "0.93";
    lang = "J";
    sha256 = "sha256-tKhPbSd9PA7G6DOsD+JbQFRe3twZ31+0ZDcx7vD3MKI=";
  };
  glowsansSC = glowsans {
    pname = "glowsans-SC";
    version = "0.93";
    lang = "SC";

    sha256 = "sha256-qi4f2yAzcROh0mcLaVv+6DkQ7vouSPUccE5fSp+OyfE=";
  };

  glowsansTC = glowsans {
    pname = "glowsans-TC";
    version = "0.93";
    lang = "TC";

    sha256 = "sha256-FuiigAGrGymIfb9jb7NiPkExeMSy/LgmBKZrudGAZUc=";
  };
}



