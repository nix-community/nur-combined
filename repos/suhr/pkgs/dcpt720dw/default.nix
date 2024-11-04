{ stdenv, lib, fetchurl
, dpkg, makeWrapper, autoPatchelfHook
, ghostscript, gnused, perl, coreutils, gnugrep, which, file
}:

let
  model = "dcpt720dw";
  arches = ["x86_64" "i686"];
  version = "3.5.0";
  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf105179/dcpt720dwpdrv-3.5.0-1.i386.deb";
    sha256 = "sha256-ToUFGnHxd6rnLdfhdDGzhvsgFJukEAVzlm79hmkSV3E=";
  };
  runtimeDeps = [
    ghostscript
    file
    gnused
    gnugrep
    coreutils
    which
  ];
in
stdenv.mkDerivation {
  pname = "cups-brother-${model}";
  inherit src version;

  nativeBuildInputs = [ dpkg makeWrapper autoPatchelfHook ];
  buildInputs = [ perl ];
  unpackPhase = "dpkg-deb -x $src $out";

  installPhase =
    ''
      runHook preInstall
    ''
    + lib.concatMapStrings (arch: ''
      echo Deleting files for ${arch}
      rm -r "$out/opt/brother/Printers/${model}/lpd/${arch}"
      '') (builtins.filter (arch: arch != stdenv.hostPlatform.linuxArch) arches)
    + ''
      # bundled scripts don't understand the arch subdirectories for some reason
      ln -s \
        "$out/opt/brother/Printers/${model}/lpd/${stdenv.hostPlatform.linuxArch}/"* \
        "$out/opt/brother/Printers/${model}/lpd/"

      # Fix global references and replace auto discovery mechanism with hardcoded values
      substituteInPlace $out/opt/brother/Printers/${model}/lpd/filter_${model} \
        --replace /opt "$out/opt" \
        --replace "my \$BR_PRT_PATH =" "my \$BR_PRT_PATH = \"$out/opt/brother/Printers/${model}\"; #" \
        --replace "PRINTER =~" "PRINTER = \"${model}\"; #"

      # Make sure all executables have the necessary runtime dependencies available
      wrapProgram "$out/opt/brother/Printers/${model}/cupswrapper/brother_lpdwrapper_${model}" \
        --prefix PATH : "${lib.makeBinPath runtimeDeps}"
      wrapProgram "$out/opt/brother/Printers/${model}/cupswrapper/cupswrapper${model}" \
        --prefix PATH : "${lib.makeBinPath runtimeDeps}"
      wrapProgram "$out/opt/brother/Printers/${model}/inf/setupPrintcapij" \
        --prefix PATH : "${lib.makeBinPath runtimeDeps}"
      wrapProgram "$out/opt/brother/Printers/${model}/lpd/filter_${model}" \
        --prefix PATH : "${lib.makeBinPath runtimeDeps}"

      # Symlink filter and ppd into a location where CUPS will discover it
      mkdir -p $out/lib/cups/filter $out/share/cups/model

      ln -s \
        $out/opt/brother/Printers/${model}/lpd/filter_${model} \
        $out/lib/cups/filter/filter_${model}

      ln -s \
        $out/opt/brother/Printers/${model}/cupswrapper/brother_${model}_printer_en.ppd \
        $out/share/cups/model/

      runHook postInstall
    '';

  meta = with lib; {
    homepage = "http://www.brother.com/";
    description = "Brother ${model} printer driver";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = builtins.map (arch: "${arch}-linux") arches;
    downloadPage = "https://support.brother.com/g/b/downloadlist.aspx?c=ru&lang=ru&prod=dcpt720dw_all&os=127";
    maintainers = with maintainers; [ suhr ];
  };
}
