{
  pkgs,
  lib,
  stdenv,

  # native build inputs
  cmake,
  ninja,
  pkg-config,

  # vcpkgs dependencies
  antlr4, # 4.13.2 or higher
  spdlog,
  gtest,
  pcre2,
  re2,
  gperftools,
  hyperscan,
  libinjection,
  libxml2,
  boost,
  #boost-uuid,
  #boost-unordered,
  #boost-interprocess,

  # non-vcpkgs dependencies
  ragel, # 6.10 specifically
  jdk, # 21 or higher
}:

let
  vcpkgFakePackage = target: name: ''
    Package : ${name}
    Architecture : ${target}
    Version : 1.0
    Status : is installed
  '';
  fakeCPPPackages = [
    "antlr4"
    "antlr4-runtime"
    "spdlog"
    "gtest"
    "pcre2"
    "re2"
    "gperftools"
    "hyperscan"
    "libinjection"
    "libxml2"
    "boost"
    #"boost-uuid"
    #"boost-unordered"
    #"boost-interprocess"
  ];
  realCPPPackages = [
    antlr4
    antlr4.runtime.cpp
    spdlog
    gtest
    pcre2.dev
    re2
    gperftools
    hyperscan
    libinjection
    libxml2
    boost.dev
  ];
  modSecurity = pkgs.fetchFromGitHub {

  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "wge";
  version = "1.0.0";
  src = pkgs.fetchFromGitHub {
    owner = "stone-rhino";
    repo = "wge";
    rev = "release-${finalAttrs.version}";
    hash = "sha256-cuQ99sJZ9vnPP/C7M2Be94ltrVwy47rDWhDRtctCyKg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    ragel
    jdk
  ]
  ++ realCPPPackages;

  env.NIX_ANTLR_JAR_PATH = "${antlr4}/share/java";
  patches = [ ./no_vcpkg.patch ];
  dontUseCmakeBuildDir = true;
  dontUseCmakeConfigurePhase = true;
  cmakeBuildType = "release";
  ninjaFlags = [
    "-C"
    "build/release"
  ];

  # this is a hack to decouple from vcpkg, which relies on fetching
  # dependencies from the internet. inspired by the method taken by
  # https://github.com/NixOS/nixpkgs/blob/release-22.11/pkgs/applications/networking/remote/rustdesk/default.nix
  postUnpack =
    let
      vcpkg_target = "x64-linux";
      updates_vcpkg_file = pkgs.writeText "update_vcpkg_wge" (
        lib.concatStringsSep "\n\n" (lib.map (vcpkgFakePackage vcpkg_target) fakeCPPPackages)
      );
    in
    ''
      export VCPKG_ROOT="$TMP/vcpkg";

      mkdir -p $VCPKG_ROOT/.vcpkg-root
      mkdir -p $VCPKG_ROOT/installed/${vcpkg_target}/lib
      mkdir -p $VCPKG_ROOT/installed/vcpkg/updates
      ln -s ${updates_vcpkg_file} $VCPKG_ROOT/installed/vcpkg/status
      mkdir -p $VCPKG_ROOT/installed/vcpkg/info
      touch $VCPKG_ROOT/installed/vcpkg/info/{${lib.concatStringsSep "," fakeCPPPackages}}_1.0_${vcpkg_target}.list
      ln -s {${lib.concatStringsSep "," (lib.catAttrs "out" realCPPPackages)}}/lib/* $VCPKG_ROOT/installed/${vcpkg_target}/lib/
    '';

  # disable benchmark from building, it pulls in ModSecurity source and tries to compile
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail "add_subdirectory(benchmarks/modsecurity)" ""
    substituteInPlace CMakeLists.txt --replace-fail "add_subdirectory(benchmarks/wge)" ""
    substituteInPlace CMakeLists.txt --replace-fail "add_dependencies(wge_install_target wge)" ""
  '';

  preConfigure = ''
    export CLASSPATH=".:$${NIX_ANTLR_JAR_PATH}/antlr-4.13.2-complete.jar:$CLASSPATH"
    alias antlr4='${jdk}/bin/java -Xmx500M -cp "$${NIX_ANTLR_JAR_PATH}/antlr-4.13.2-complete.jar:$CLASSPATH" org.antlr.v4.Tool'
    alias grun='${jdk}/bin/java -Xmx500M -cp "$${NIX_ANTLR_JAR_PATH}/antlr-4.13.2-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig'
  '';

  configurePhase = ''
    runHook preConfigure
    cmake --preset=release
    runHook postConfigure
  '';
  buildPhase = ''
    cmake --build build/release
  '';
  installPhase = ''
    cmake --install build/release --prefix $out
  '';

  doCheck = true;
  checkPhase = ''
    ./build/release/test/test
  '';

  meta = {
    description = "Web application firewall built with C++ and compatible with OWASP Core Rule Set.";
    homepage = "https://stone-rhino.github.io/wge/";
    downloadPage = "https://github.com/stone-rhino/wge/releases/tag/release-1.0.0";
    license = lib.licenses.mit;
    maintainers = [];
  };
})
