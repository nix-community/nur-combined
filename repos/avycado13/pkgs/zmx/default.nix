{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  ...
}:

stdenv.mkDerivation rec {
  pname = "zmx";
  version = "0.4.1";

  src = fetchurl {
    url =
      if stdenv.isLinux then
        (
          if stdenv.isAarch64 then
            "https://zmx.sh/a/zmx-${version}-linux-aarch64.tar.gz"
          else
            "https://zmx.sh/a/zmx-${version}-linux-x86_64.tar.gz"
        )
      else if stdenv.isDarwin then
        (
          if stdenv.isAarch64 then
            "https://zmx.sh/a/zmx-${version}-macos-aarch64.tar.gz"
          else
            "https://zmx.sh/a/zmx-${version}-macos-x86_64.tar.gz"
        )
      else
        throw "Unsupported platform";

    hash =
      if stdenv.isLinux && stdenv.isAarch64 then
        "sha256-wD3GnIo/zYDyFMfYcw7zDP+rJeHcoFsjkjkeeEYvN6s="
      else if stdenv.isLinux then
        "sha256-6bZbakDdXIj5toN2oFoOzGrHfuu7pE8WKfTbjoO2Eag="
      else if stdenv.isDarwin && stdenv.isAarch64 then
        "sha256-SlShkwyaKmRyGmBL5/PSy+xN/Ft7z9BsQs3pEUc81QU="
      else
        "sha256-Tlxh+pbVN3kC7x5dZsuIlAn5BHTSeH5MMEvrJmEbTRw=";
  };

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp zmx $out/bin/
    chmod +x $out/bin/zmx
    runHook postInstall
  '';

  meta = with lib; {
    description = "Session persistence for terminal processes";
    homepage = "https://zmx.sh";
    license = licenses.mit;
    platforms = platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
