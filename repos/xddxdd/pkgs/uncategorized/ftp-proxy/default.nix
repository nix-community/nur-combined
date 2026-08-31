{
  fetchurl,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ftp-proxy";
  version = "1.2.3";
  src = fetchurl {
    url = "http://www.ftpproxy.org/download/ftpproxy-${finalAttrs.version}.tgz";
    hash = "sha256-36r+iOaKEA9DMHBufEW+eoiRlEu1+VsYaWvK957l1uU=";
  };
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

  passthru.updateScript = [ (toString ./update.sh) ];
  meta = {
    mainProgram = "ftp.proxy";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "FTP Proxy Server";
    homepage = "http://www.ftpproxy.org/";
    license = lib.licenses.gpl2Only;
  };
})
