{ lib
, stdenv
, fetchurl
, electron
, makeWrapper
, unzip
}:
stdenv.mkDerivation rec {
  pname = "aliyunpan";
  version = "2.9.24";

  src = fetchurl {
    url = "https://github.com/liupan1890/aliyunpan/releases/download/v${version}/Linux.v${version}.zip";
    sha256 = "sha256-sOrRSo5oEZpvxP/FkTMI/9oXCQ3K3DuA347Z7MzPh1o=";
  };

  nativeBuildInputs = [ unzip makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin $out/share
    cp -a electron/{locales,resources} $out/share/

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/resources/app.asar \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc ]}"
  '';

  meta = with lib; {
    homepage = "https://github.com/liupan1890/aliyunpan";
    description = "PC client developed based on Alibaba cloud disk web version
";
    license = "unknown";
    platforms = platforms.linux;
  };
}

