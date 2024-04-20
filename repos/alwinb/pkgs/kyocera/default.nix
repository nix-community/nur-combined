{ stdenv, lib, fetchzip, cups, autoPatchelfHook

  # Can either be "EU" or "Global"; it's unclear what the difference is
  , region ? "Global", qt4
}:

let
  platform =
    if stdenv.hostPlatform.system == "x86_64-linux" then "64bit"
    else if stdenv.hostPlatform.system == "i686-linux" then "32bit"
         else throw "Unsupported system: ${stdenv.hostPlatform.system}";
  debPlatform =
    if platform == "64bit" then "amd64"
    else "i386";
  debRegion = if region == "EU" then "EU." else "";
in
stdenv.mkDerivation rec {
  pname = "cups-ecosys-m6x3xcdn";
  version = "8.1410";

  dontStrip = true;

  src = fetchzip {
    url = "https://www.kyoceradocumentsolutions.de/content/download-center/de/drivers/all/Linux_Ecosys_M_P6x3xcdn_zip.download.zip";
    sha256 = "sha256-n7CtEX1P4AaxDZU7166xaXIq8+UvzdqPhHKAhK+KYcs=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ cups qt4 ];

  installPhase = ''
    mkdir -p $out
    cd $out
    # unpack the debian archive
    #unzip -d . Linux_Ecosys_M-P6x3xcdn.zip


    #ar p ${src}/KyoceraLinuxPackages/${region}/${platform}/kyodialog3.en${debRegion}_0.5-0_${debPlatform}.deb data.tar.gz | tar -xz
    #rm -Rf KyoceraLinuxPackages
    # strip $out/usr
    #rmdir usr
    # allow cups to find the ppd files
    mkdir -p share/cups/model/Kyocera
    ls ${src}
    cp ${src}/${region}/English/* share/cups/model/Kyocera/
    #mv share/ppd/kyocera share/cups/model/Kyocera
    #rmdir share/ppd
    #rm -r Linux
    # prepend $out to all references in ppd and desktop files
    find -name "*.ppd" -exec sed -E -i "s:/usr/lib:$out/lib:g" {} \;
    find -name "*.desktop" -exec sed -E -i "s:/usr/lib:$out/lib:g" {} \;
  '';

  meta = with lib; {
    description = "CUPS drivers for several Kyocera printers";
    homepage = "https://www.kyoceradocumentsolutions.com";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
