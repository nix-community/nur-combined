{
  lib,
  autoPatchelfHook,
  cups,
  fetchzip,
  ghostscript,
  libgcc,
  makeWrapper,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mccgdi";
  version = "2.0.10";

  src = fetchzip {
    url = "https://www.psn-web.net/cs/support/fax/common/file/Linux_PrnDriver/Driver_Install_files/mccgdi-${finalAttrs.version}-x86_64.tar.gz";
    hash = "sha256-cDXkQwzom4RmLQ9m9EegoRNRdGUUaUk3C4Qfn11V7qw=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    libgcc.lib
  ];

  buildPhase = ''
    substitute ${./hook.c} hook.c \
      --replace-fail "@cups@" ${cups.lib} \
      --replace-fail "@ghostscript@" ${ghostscript} \
      --replace-fail "@datadir@" $out/share \
      --replace-fail "@libdir@" $out/lib
    cc -shared -fPIC hook.c -o libhook.so
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp libhook.so $out/lib/

    mkdir -p $out/lib/cups/filter
    cp filter/L_H0JDGCZAZ $out/lib/cups/filter/

    mkdir -p $out/share/cups/model/panasonic
    cp ppd/* $out/share/cups/model/panasonic/

    mkdir -p $out/share/panasonic/printer/data
    cp -r data/* $out/share/panasonic/printer/data/

    for file in L_H0JDJCZAZ_2 L_H0JDJCZAZ; do
      cp lib/$file.so.1.0.0 $out/lib/
      ln -s $file.so.1.0.0 $out/lib/$file.so.1
      ln -s $file.so.1 $out/lib/$file.so
    done
  '';

  postFixup = ''
    wrapProgram $out/lib/cups/filter/L_H0JDGCZAZ \
      --set LD_PRELOAD $out/lib/libhook.so
  '';

  meta = {
    description = "Panasonic multi-function station printer drivers";
    homepage = "https://docs.connect.panasonic.com/pcc/support/fax/";
    downloadPage = "https://docs.connect.panasonic.com/pcc/support/fax/common/table/linuxdriver.html";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ prince213 ];
    platforms = [ "x86_64-linux" ];
  };
})
