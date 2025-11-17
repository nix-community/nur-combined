{
  pkgs,
  drv,
  goos,
  goarch,
}:
drv.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "${previousAttrs.pname}-${goos}-${goarch}";
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

    nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ pkgs.upx ];

    # compress binary
    postInstall = ''
      FILE=$(find "''${out}" -type f -print -quit)
      TMP_FILE="''${TMPDIR:-/tmp}/bin"

      mv "''${FILE}" "''${TMP_FILE}"
      rm -rf "''${out}"
      upx --best --lzma "''${TMP_FILE}" || true

      cat "''${TMP_FILE}" > "''${out}"
      chmod +x "''${out}"
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
)
