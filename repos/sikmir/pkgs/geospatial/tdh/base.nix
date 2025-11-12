{
  lib,
  stdenv,
  fetchgdrive,
  unzip,
  gsettings-desktop-schemas,
  gtk3,
  wxgtk,
  libredirect,
  makeWrapper,
  wrapGAppsHook3,
  pname,
  version,
  id,
  sha256,
  description,
  homepage,
}:

stdenv.mkDerivation {
  inherit pname version;

  src = fetchgdrive {
    inherit id sha256;
    name = "${pname}_linux64.zip";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
    unzip
  ];

  buildInputs = [
    gsettings-desktop-schemas
    gtk3
  ];

  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    [ -f ${pname} ] && install -Dm755 ${pname} -t $out/bin
    [ -f ${pname}_linux ] && install -Dm755 ${pname}_linux $out/bin/${pname}
    install -Dm644 *.so -t $out/lib
    install -Dm644 *.{pdf,txt} -t $out/share/doc/${pname}
    install -dm755 $out/share/${pname}
    cp -r *_Structure $out/share/${pname}
  '';

  preFixup = ''
    patchelf --replace-needed "./libTdhCairo.so" libTdhCairo.so \
      --replace-needed "./libTdhCommon.so" libTdhCommon.so \
      --replace-needed "./libTdhVGbase.so" libTdhVGbase.so \
      --replace-needed "./libTdhWx.so" libTdhWx.so \
      $out/bin/${pname}

    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      --set-rpath "$out/lib:${
        lib.makeLibraryPath [
          stdenv.cc.cc.lib
          wxgtk
        ]
      }" \
      $out/bin/${pname}

    gappsWrapperArgs+=(
      --set LD_PRELOAD "${libredirect}/lib/libredirect.so" \
      --set NIX_REDIRECTS "$out/bin/${pname}_Structure=$out/share/${pname}/${pname}_Structure"
    )
  '';

  preferLocalBuild = true;

  meta = {
    inherit description homepage;
    license = lib.licenses.cc-by-nc-sa-40;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = [ "x86_64-linux" ];
    skip.ci = true;
    broken = true; # wxGTK30 has been removed from nixpkgs as it has reached end of life
  };
}
