{
  stdenv,
  lib,
  sources,
  cmake,
  pkg-config,
  oniguruma,
}:
stdenv.mkDerivation {
  inherit (sources.qsp-lib) pname version src;

  prePatch = ''
    install -Dm644 ${./QspConfig.cmake.in} QspConfig.cmake.in
    substituteInPlace CMakeLists.txt \
      --replace-fail " onig " " "
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [ oniguruma ];

  cmakeFlags = [ "-DUSE_INSTALLED_ONIGURUMA=ON" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Interactive fiction development platform (Game Library)";
    homepage = "https://github.com/QSPFoundation/qsp";
    license = lib.licenses.gpl2Only;
  };
}
