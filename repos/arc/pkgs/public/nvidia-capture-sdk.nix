{ stdenv
, lib
, requireFile
, unzip
, msitools
}: with lib; stdenv.mkDerivation rec {
  pname = "nvidia-capture-sdk";
  version = if stdenv.isLinux
    then "8.0.4"
    else "7.1.1";

  src = requireFile {
    url = "https://developer.nvidia.com/capture-sdk";
    name = if stdenv.isLinux
      then "Capture_Linux_v${version}.tgz"
      else "NVIDIA-Capture-SDK-${version}.zip";
    sha256 = if stdenv.isLinux
      then "17mbwnm28dj2bp0k3wyx7vwwzj6ysarjfdhykm8fhqha471g1pv2"
      else "1v1lvrpmf3lby1kih5f3x69qj4dlxm0cmgji947byyi8dypaahx5";
  };

  nativeBuildInputs = optionals stdenv.hostPlatform.isWindows [ unzip msitools ];

  unpackPhase = optionalString stdenv.hostPlatform.isWindows ''
    unzip $src
    msiextract NVIDIA-Capture-SDK-${version}.msi
  '';

  buildPhase = ":";

  outputs = [ "out" "sdk" ];

  nvPrefix = if stdenv.isLinux
    then "NvFBC"
    else "Program Files/NVIDIA Corporation/NVIDIA Capture SDK";

  installPhase = ''
    runHook preInstall

    install -d $out
    mv "$nvPrefix/inc" $out/include

    install -d $sdk
    ln -s $out/include $sdk/inc

    if [[ -d "$nvPrefix/bin" ]]; then
      mv "$nvPrefix/bin" $out/
      ln -s $out/bin $sdk/bin
    fi

  '' + optionalString stdenv.hostPlatform.isWindows ''
    ln -s NvEncodeAPI/NvEncodeAPI.h $out/nvEncodeAPI.h
    ln -s NvFBC/nvFBC.h $out/NvFBC.h
  '' + ''
    runHook postInstall
  '';

  postFixup = optionalString stdenv.hostPlatform.isMinGW ''
    sed -i -e 's/Windows\.h/windows.h/' $out/include/NvFBC/*.h
  '';

  meta = {
    license = licenses.unfree;
    platforms = with platforms; linux ++ windows;
  };
}
