{
  lib,
  pkgs,
  stdenv,

  cmake,

  spdlog,
  boost,
  wge,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wge-apic";
  version = "2025-11-07";
  src = pkgs.fetchFromGitHub {
    owner = "stone-rhino";
    repo = "wge-connectors";
    rev = "7b89d7be1bdc11b8a2b67f25ce8b58bfc113a85d";
    hash = "sha256-9pk6aC5hsCmZCHxE36ypx6WZkhL9L0+4/kVnKu3I12U=";
  };
  sourceRoot = "${finalAttrs.src.name}/wge-apic";
  nativeBuildInputs = [ cmake ];
  buildInputs = [
    spdlog
    boost
    wge
  ];
  patches = [ ./no_vcpkg.patch ];
  patchFlags = [ "-p2" ];
  # std::expected
  env.CXXFLAGS = "-std=gnu++23";
  # pass into CMakeLists
  env.NIX_WGE_PATH = "${wge}";

  configurePhase = "cmake -Wno-author .";
  preInstall = ''
    echo BUILD PHASE FINISHED
    echo directories:
    ls -R .
  '';
  installPhase = ''
    mkdir -p $out/lib
    mkdir -p $out/include
    cp libwge_apic.a $out/lib
    cp *.h $out/include
  '';

  meta = {
    description = "C API for WGE";
    homepage = "https://github.com/stone-rhino/wge-connectors";
    license = lib.licenses.mit;
  };
})
