{
  stdenv,
  sources,
  lib,
  ...
}:
stdenv.mkDerivation rec {
  inherit (sources.netns-exec) pname version src;
  buildPhase = ''
    runHook preBuild

    substituteInPlace Makefile --replace "-m4755" "-m755"

    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    make install PREFIX=$out

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Run command in Linux network namespace as normal user";
    homepage = "https://github.com/pekman/netns-exec";
    license = licenses.gpl2Only;
  };
}
