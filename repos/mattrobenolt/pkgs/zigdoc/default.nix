{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  zig_0_15,
}:

stdenvNoCC.mkDerivation {
  pname = "zigdoc";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "rockorager";
    repo = "zigdoc";
    rev = "v0.2.2";
    hash = "sha256-bvZnNiJ6YbsoQb41oAWzZNErCcAtKKudQMwvAfa4UEA=";
  };

  nativeBuildInputs = [ zig_0_15 ];

  postPatch = ''
    substituteInPlace build.zig \
      --replace-fail '"../README.md"' '"README.md"'
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
