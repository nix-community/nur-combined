{
  stdenv,
  sources,
  fd,
}:
stdenv.mkDerivation {
  inherit (sources.codestable) pname version src;
  nativeBuildInputs = [ fd ];
  dontBuild = true;
  installPhase = ''
    mkdir "$out"
    fd 'SKILL\.md' --exec cp --verbose --recursive "{//}" "$out/"
  '';
}
