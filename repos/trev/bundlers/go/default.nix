{
  drv,
  goos,
  goarch,
  normalized,
}:
drv.overrideAttrs (
  finalAttrs: previousAttrs:
  let
    binName = if goos == "windows" then "${previousAttrs.pname}.exe" else previousAttrs.pname;
  in
  {
    pname = "${previousAttrs.pname}-${normalized}";

    # build for specific GOOS and GOARCH
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

    meta.mainProgram = binName;
  }
)
