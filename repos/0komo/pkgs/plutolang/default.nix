{
  clangStdenv,
  lld,
  fetchFromGitHub,
  lib,
  php,
  makeWrapper,
  gcc-unwrapped,
  ...
}:
let
  stdenv = clangStdenv;
in
stdenv.mkDerivation rec {
  pname = "plutolang";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = pname;
    repo = "pluto";
    rev = version;
    hash = "sha256-95hQ8qC3W/58vi4UiGyItpOSi0eGi4LHnGwy3XCLBz0=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ makeWrapper php lld ];

  buildInputs = [ stdenv.cc.cc.lib ];

  buildPhase = ''
    runHook preBuild

    export CXX="${stdenv.cc.targetPrefix}c++"

    php scripts/compile.php "$CXX"
    php scripts/link_pluto.php "$CXX"
    php scripts/link_plutoc.php "$CXX"
    php scripts/link_shared.php "$CXX"
    php scripts/link_static.php "$CXX"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$dev/"{lib,include}

    cp src/pluto{,c} "$out/bin"
    cp src/libpluto* "$dev/lib"
    cp src/{lua,lualib,lauxlib}.h src/lua.hpp "$dev/include"

    for x in "$out/bin"/*; do
      wrapProgram "$x" --prefix LD_LIBRARY_PATH : ${gcc-unwrapped.lib}/lib
    done

    runHook postInstall
  '';


  meta = with lib; {
    description = "A superset of Lua 5.4 with a focus on general-purpose programming";
    homepage = "https://pluto-lang.org";
    maintainers = [ ];
    platforms = platforms.all;
  };
}
