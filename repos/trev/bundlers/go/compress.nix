{
  pkgs,
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

    meta.mainProgram = binName;
  }
)
