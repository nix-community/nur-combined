{ lib
, stdenvNoCC
, fetchFromGitHub
, zig_0_15
,
}:

stdenvNoCC.mkDerivation {
  pname = "zigdoc";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "rockorager";
    repo = "zigdoc";
    rev = "v0.1.0";
    hash = "sha256-nClG2L4ac0Bu+dGkanSFjoLHszeMoUFV9BdBEEKkdhA=";
  };

  nativeBuildInputs = [ zig_0_15 ];

  dontConfigure = true;
  dontInstall = true;

  preBuild = "export HOME=$TMPDIR";

  buildPhase = ''
    runHook preBuild
    zig build --prefix $out -Doptimize=ReleaseSafe
    runHook postBuild
  '';

  meta = with lib; {
    description = "Generate documentation from Zig source code";
    homepage = "https://github.com/rockorager/zigdoc";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "zigdoc";
    platforms = platforms.all;
  };
}
