{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
let
  mkArboreal =
    {
      source,
      meta,
      cmakeFlags ? [ ],
    }:
    lib.makeOverridable (
      {
        noLicenseCheck ? false,
        productionBuild ? true,
      }:
      stdenv.mkDerivation {
        inherit (source) pname version src;

        nativeBuildInputs = [ juceCmakeHook ];

        cmakeFlags =
          cmakeFlags
          ++ (lib.optional noLicenseCheck "-DNO_LICENSE_CHECK=1")
          ++ lib.optional productionBuild "-DPRODUCTION_BUILD=1";

        meta = {
          license = lib.licenses.gpl3Plus;
          platforms = lib.platforms.linux;
          maintainers = [ lib.maintainers.bandithedoge ];
        }
        // meta;
      }
    ) { };
in
{
  str-x = mkArboreal {
    source = sources.str-x;
    meta = {
      homepage = "https://arborealaudio.com/plugins/str-x";
      description = "Not your grandpa's guitar amp";
    };
  };

  pimax = mkArboreal {
    source = sources.pimax;
    cmakeFlags = [
      "-DFETCHCONTENT_SOURCE_DIR_JUCE=${sources.juce.src}"
      "-DFETCHCONTENT_SOURCE_DIR_CLAP-JUCE-EXTENSIONS=${sources.clap-juce-extensions.src}"
      "-DFETCHCONTENT_SOURCE_DIR_PFFFT=${sources.pffft.src}"
    ];
    meta = {
      homepage = "https://arborealaudio.com/plugins/pimax";
      description = "Make It Loud";
    };
  };

  omniamp = mkArboreal {
    source = sources.omniamp;
    meta = {
      homepage = "https://arborealaudio.com/plugins/omniamp";
      description = "All-in-one amplifier";
    };
  };
}
