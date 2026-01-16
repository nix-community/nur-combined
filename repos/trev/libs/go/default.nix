{ pkgs }:
{
  toPlatform =
    goModule: goos: goarch:
    goModule.overrideAttrs (
      finalAttrs: previousAttrs: {
        env = previousAttrs.env // {
          GOOS = goos;
          GOARCH = goarch;
        };

        doCheck = false;

        # normalize cross-compiled builds
        postBuild = ''
          dir=$GOPATH/bin/''${GOOS}_''${GOARCH}
          if [[ -n "$(shopt -s nullglob; echo $dir/*)" ]]; then
            mv $dir/* $dir/..
          fi
          if [[ -d $dir ]]; then
            rmdir $dir
          fi
        '';

        meta =
          if builtins.hasAttr "meta" previousAttrs then
            if builtins.hasAttr "mainProgram" previousAttrs.meta && goos == "windows" then
              previousAttrs.meta // { mainProgram = "${previousAttrs.meta.mainProgram}.exe"; }
            else
              previousAttrs.meta
          else
            { };
      }
    );

  toImage =
    goModule:
    pkgs.dockerTools.buildImage {
      name = "${goModule.pname}";
      tag = "${goModule.version}";
      created = "now";
      meta = goModule.meta;
      architecture = "${goModule.GOARCH}";
      copyToRoot = [ goModule ];
      config.Cmd = [
        "${pkgs.lib.meta.getExe goModule}"
      ];
    };
}
