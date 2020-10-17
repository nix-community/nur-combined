{ callPackage }:
let
  mkPlugin = callPackage ./build-plugin.nix {
    jetbrainsPlatforms = [
      "clion"
      "datagrip"
      "goland"
      "idea-community"
      "idea-ultimate"
      "phpstorm"
      "pycharm-community"
      "pycharm-professional"
      "rider"
      "ruby-mine"
      "webstorm"
    ];
  };
in
{
  ideavim = mkPlugin {
    pname = "IdeaVim";
    version = "0.57";
    pluginId = 164;
    versionId = 85009;
    sha256 = "1rwfwj0b0nwi7jxhzxk1r0xc190nf4i3b59i0zknpmgb4yc5clzw";
  };

  checkstyle-idea = mkPlugin {
    pname = "CheckStyle-IDEA";
    version = "5.42.0";
    pluginId = 1065;
    versionId = 95757;
    sha256 = "0sji3649n5zz84dlidqaklipq6vaiafxsvg0gzy3j59mvkz6dk14";
  };

  google-java-format = mkPlugin rec {
    pname = "google-java-format";
    version = "1.7.0.4";
    pluginId = 8527;
    versionId = 83164;
    sha256 = "1pmnn1ksiv44kdga53gi3psrm2sva4bqrxizagbr0if2n0rrvgii";
    filename = "${pname}.zip";
  };
}
