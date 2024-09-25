{
  lib,
  stdenv,
  sources,
  ...
}:
stdenv.mkDerivation rec {
  inherit (sources.ftp-proxy) pname version src;

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

  meta = with lib; {
    mainProgram = "ftp.proxy";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "ftp.proxy - FTP Proxy Server";
    homepage = "http://www.ftpproxy.org/";
    license = licenses.gpl2Only;
  };
}
