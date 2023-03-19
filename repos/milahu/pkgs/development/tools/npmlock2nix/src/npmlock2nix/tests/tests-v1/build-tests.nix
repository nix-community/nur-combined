{ lib, symlinkJoin, npmlock2nix, runCommand, libwebp, python3 }:
let
  symlinkAttrs = attrs: runCommand "symlink-attrs"
    { }
    (
      let
        drvs = lib.attrValues (lib.mapAttrs (name: drv: { inherit name drv; }) attrs);
      in
      ''
          mkdir $out
        ${lib.concatMapStringsSep "\n" (o: "ln -s ${o.drv} $out/${o.name}") drvs}
      ''
    );
in
symlinkAttrs {
  webpack-cli-project-default-build-command = npmlock2nix.v1.build {
    src = ./examples-projects/webpack-cli-project;
    installPhase = ''
      cp -r dist $out
    '';
  };

  webpack-cli-project-custom-build-command = npmlock2nix.v1.build {
    src = ./examples-projects/webpack-cli-project;
    buildCommands = [ "webpack --mode=production" ];
    installPhase = ''
      cp -r dist $out
    '';
  };

  node-modules-attributes-are-passed-through = npmlock2nix.v1.build {
    src = ./examples-projects/bin-wrapped-dep;
    buildCommands = [
      ''
        readlink -f $(node -e "console.log(require('cwebp-bin'))") > actual
        echo ${libwebp}/bin/cwebp > expected
      ''
    ];
    installPhase = ''
      cp actual $out
    '';

    doCheck = true;
    checkPhase = ''
      cmp actual expected || exit 1
    '';

    node_modules_attrs = {
      preInstallLinks = {
        "cwebp-bin"."vendor/cwebp" = "${libwebp}/bin/cwebp";
      };
    };
  };

  passsing-buildInputs-doesnt-break-the-build = npmlock2nix.v1.build {
    src = ./examples-projects/webpack-cli-project;
    installPhase = ''
      cp -r dist $out
    '';

    buildInputs = [ python3 ];
  };
}
