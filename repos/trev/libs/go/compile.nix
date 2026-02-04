{
  lib,
  stdenv,
}:
{
  compile = lib.makeOverridable (
    {
      package,
      goos ? stdenv.buildPlatform.go.GOOS,
      goarch ? stdenv.buildPlatform.go.GOARCH,
      ...
    }:
    package.overrideAttrs (
      _: prev:
      let
        name = if (builtins.hasAttr "pname" prev) then prev.pname else prev.name;
        bin = if (goos == "windows") then "${name}.exe" else name;
      in
      {
        env = prev.env // {
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

        meta = prev.meta // {
          mainProgram = bin;
        };
      }
    )
  );
}
