{
  lib,
  stdenv,
  fetchFromGitHub,
  libiconv,
}:

let
  cc = "${stdenv.cc.targetPrefix}cc";
  cxx = "${stdenv.cc.targetPrefix}c++";
  ar = "${stdenv.cc.targetPrefix}ar";
in
stdenv.mkDerivation rec {
  pname = "makerom";
  version = "0.18.4";

  src = fetchFromGitHub {
    owner = "3DSGuy";
    repo = "Project_CTR";
    rev = "makerom-v${version}";
    sha256 = "sha256-XGktRr/PY8LItXsN1sTJNKcPIfnTnAUQHx7Om/bniXg=";
  };

  buildInputs = [ libiconv ];

  postPatch = ''
    # because substituteInPlace is a shell function, we can't use find -exec
    for f in $(find makerom -name "makefile"); do
      substituteInPlace $f \
        --replace-fail @ar ${ar} \
        --replace-warn @gcc ${cc}
    done
  '';

  preBuild = ''
    cd makerom
    make SHELL=${stdenv.shell} -j$NIX_BUILD_CORES deps ${lib.escapeShellArgs makeFlags}
  '';

  makeFlags = [
    "CC=${cc}"
    "CXX=${cxx}"
  ];
  enableParallelBuilding = true;

  installPhase = ''
    mkdir $out/bin -p
    cp bin/makerom${stdenv.hostPlatform.extensions.executable} $out/bin/
  '';

  meta = with lib; {
    license = licenses.mit;
    description = "make 3ds roms";
    homepage = "https://github.com/3DSGuy/Project_CTR";
    platforms = platforms.all;
    mainProgram = "makerom";
  };
}
