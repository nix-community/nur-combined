{
  lib,
  stdenv,
  sources,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.ftp-proxy) pname version src;

  postPatch = ''
    substituteInPlace src/ip-lib.c \
      --replace-fail ", *gethostbyname();" ";" \
      --replace-fail "static void alarm_handler()" "static void alarm_handler(int unused)"
  '';

  buildPhase = ''
    runHook preBuild

    cd src && make clean && make

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 ftp.proxy $out/bin/ftp.proxy

    runHook postInstall
  '';

  meta = {
    mainProgram = "ftp.proxy";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "FTP Proxy Server";
    homepage = "http://www.ftpproxy.org/";
    license = lib.licenses.gpl2Only;
  };
})
