{
  stdenv,
  lib,
  sources,
  cmake,
  ...
}:
stdenv.mkDerivation rec {
  inherit (sources.libltnginx) pname version src;

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 libltnginx.so $out/lib/libltnginx.so

    runHook postInstall
  '';

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Libltnginx";
    homepage = "https://github.com/xddxdd/libltnginx";
    license = licenses.gpl3Only;
  };
}
