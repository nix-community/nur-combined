{
  pkgs,
  sources,
  utils,
  ...
}: let
  mkArboreal = {
    source,
    meta,
    cmakeFlags ? [],
  }:
    pkgs.makeOverridable ({
      noLicenseCheck ? false,
      productionBuild ? true,
    }:
      utils.juce.mkJucePackage {
        inherit (source) pname version src;

        cmakeFlags =
          cmakeFlags
          ++ (pkgs.lib.optional noLicenseCheck "-DNO_LICENSE_CHECK=1")
          ++ pkgs.lib.optional productionBuild "-DPRODUCTION_BUILD=1";

        meta = with pkgs.lib;
          {
            license = licenses.gpl3Only;
            platforms = platforms.linux;
          }
          // meta;
      }) {};
in {
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
