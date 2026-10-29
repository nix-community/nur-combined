{
  lib,
  stdenv,
  autoPatchelfHook,
  patchelf,
  requireFile,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vivado-unwrapped";
  version = "2025.2.1";

  src = requireFile {
    name = "FPGAs_AdaptiveSoCs_Unified_SDI_2025.2.1_0320_0604.tar";
    hash = "sha256-nTHt15n9zrYZiHuDM33bkdDzBvwG7mA4RPlOszwB7y4=";
    message = ''
      The AMD Vivado ${finalAttrs.version} installer cannot be downloaded automatically.
      Download FPGAs_AdaptiveSoCs_Unified_SDI_2025.2.1_0320_0604.tar from
      https://www.xilinx.com/support/download.html and add it to the Nix store with:
      nix store add --mode flat /path/to/FPGAs_AdaptiveSoCs_Unified_SDI_2025.2.1_0320_0604.tar
    '';
  };

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    patchelf
    writableTmpDirAsHomeHook
  ];

  # vendor-tree deps resolve at runtime through the FHS wrapper, so nothing
  # here needs to be satisfied at build time
  autoPatchelfIgnoreMissingDeps = [ "*" ];
  # --ignore-existing keeps autoPatchelf from resolving bundled libraries of
  # the tree into rpaths (which would bake build-time-only paths)
  autoPatchelfFlags = [ "--ignore-existing" ];
  # the hook's automatic run is in postFixup, too late for the vendor
  # installer that must execute during installPhase; autoPatchelf is called
  # manually in postPatch instead
  dontAutoPatchelf = true;

  dontBuild = true;
  doInstallCheck = true;
  dontStrip = true;
  dontPatchELF = true;

  passthru.edition = "Vivado ML Standard";

  # the 104G installer image is unpacked under $out (disk-backed store),
  # not the build tmpdir, and deleted in postFixup
  unpackPhase = ''
    runHook preUnpack
    mkdir -p $out/image
    tar -xf $src -C $out/image
    runHook postUnpack
  '';

  postPatch = ''
    cd $out/image/FPGAs_AdaptiveSoCs_Unified_SDI_2025.2.1_0320_0604

    patchShebangs xsetup bin scripts installLibs.sh
    sed -i -e 's#^"/bin/rm -rf#rm -rf#' -e 's#^/bin/rm -rf#rm -rf#' xsetup

    # the image already contains everything the installer copies out, so one
    # pass patches the JRE xsetup execs together with the installed tree
    autoPatchelf -- .
  '';

  installPhase = ''
    runHook preInstall

    sed "s#^Destination=.*#Destination=$out#; /^Modules=/ s/:0/:1/g" ${./install-config.txt} > install_config.txt

    bash ./xsetup -a XilinxEULA,3rdPartyEULA -b Install -c install_config.txt

    cp data/images/xlnx_logo-128x128.png vivado-icon.png || true
    install -Dm644 vivado-icon.png $out/share/icons/hicolor/128x128/apps/vivado.png

    runHook postInstall
  '';

  preFixup = ''
    # auditTmpdir (fixupOutputHook) flags rpaths starting with /build/; several
    # legacy ISE libs shipped by upstream carry build-machine paths there.
    # Those rpaths are inert in practice (all deps resolve at runtime), just
    # drop the /build/ components before the audit runs.
    # awk instead of grep so an all-/build/ rpath doesn't exit 1 under
    # `set -o pipefail` and kill the builder
    while IFS= read -r -d "" f; do
      if head -c 4 "$f" | LC_ALL=C grep -q $'\x7fELF'; then
        if rp=$(patchelf --print-rpath "$f" 2>/dev/null) && [ -n "$rp" ]; then
          cleaned=$(printf '%s' "$rp" | awk -F: '{o=""; for (i=1; i<=NF; i++) if ($i !~ /^\/build\//) o = o (o == "" ? "" : ":") $i; print o}')
          if [ "$cleaned" != "$rp" ]; then
            patchelf --set-rpath "$cleaned" "$f"
          fi
        fi
      fi
    done < <(find $out -type f -print0)

    # upstream SDK bundles ship dangling symlinks (e.g. certs -> a CA dir only
    # produced by make-ca on real systems); noBrokenSymlinks would reject them
    find $out -xtype l -delete
  '';

  postFixup = ''
    rm -rf $out/image
    cd $NIX_BUILD_TOP
  '';

  # checks must run after install (stdenv runs checkPhase before installPhase)
  installCheckPhase = ''
    runHook preInstallCheck
    test -d $out/.xinstall/${finalAttrs.version}
    test -f $out/${finalAttrs.version}/Vivado/settings64.sh
    test -f $out/${finalAttrs.version}/Vivado/bin/vivado
    runHook postInstallCheck
  '';

  meta = {
    description = "AMD Vivado ML Standard design suite";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    maintainers = [ { github = "xddxdd"; } ];
  };
})
