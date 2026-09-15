{
  pkgs,
  self,
}:

let
  inherit (pkgs) lib;

  target = "test-target";
  mkImage = import ../../libs/mkImage {
    inherit lib;
    stdenv.hostPlatform.config = target;
    dockerTools.buildLayeredImage = args: args;
  };

  basePackage = pkgs.writeShellScriptBin "image-command" "true";
  package = basePackage // {
    pname = "image-package";
    version = "1.2.3";
    stdenv.hostPlatform.go.GOARCH = "test-architecture";
    meta = {
      mainProgram = "image-command";
      description = "short description";
      longDescription = "long description";
      homepage = "https://example.invalid/home";
      downloadPage = "https://example.invalid/source";
      license = lib.licenses.mit;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  };

  unusedPackage = package // {
    pname = "unused-package";
  };

  defaults = mkImage {
    src = {
      ${target} = package;
      unused = unusedPackage;
    };
    passthruValue = "preserved";
  };

  overrides = mkImage {
    src = package;
    name = "custom-name";
    tag = "custom-tag";
    architecture = "custom-architecture";
    meta.custom = true;
    config = {
      Entrypoint = "/custom-entrypoint";
      Env = [ "EXAMPLE=value" ];
      Labels.custom = "label";
    };
  };
in
{
  mkImage-defaults =
    assert defaults.name == "image-package";
    assert defaults.tag == "1.2.3";
    assert defaults.architecture == "test-architecture";
    assert defaults.config.Entrypoint == [ (lib.getExe package) ];
    assert defaults.config.Labels."org.opencontainers.image.title" == "image-package";
    assert defaults.config.Labels."org.opencontainers.image.description" == "long description";
    assert defaults.config.Labels."org.opencontainers.image.version" == "1.2.3";
    assert defaults.config.Labels."org.opencontainers.image.url" == "https://example.invalid/home";
    assert defaults.config.Labels."org.opencontainers.image.source" == "https://example.invalid/source";
    assert defaults.config.Labels."org.opencontainers.image.licenses" == "MIT";
    assert
      defaults.meta.platforms == [
        "x86_64-linux"
        "aarch64-linux"
      ];
    assert defaults.passthruValue == "preserved";
    assert !(defaults ? src);
    pkgs.runCommand "mkImage-defaults" { } "touch $out";

  mkImage-overrides =
    assert overrides.name == "custom-name";
    assert overrides.tag == "custom-tag";
    assert overrides.architecture == "custom-architecture";
    assert overrides.config.Entrypoint == [ "/custom-entrypoint" ];
    assert overrides.config.Env == [ "EXAMPLE=value" ];
    assert overrides.config.Labels.custom == "label";
    assert overrides.config.Labels."org.opencontainers.image.title" == "image-package";
    assert overrides.meta.custom;
    assert
      overrides.meta.platforms == [
        "x86_64-linux"
        "aarch64-linux"
      ];
    pkgs.runCommand "mkImage-overrides" { } "touch $out";
}
