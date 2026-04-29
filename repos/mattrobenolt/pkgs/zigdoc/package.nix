{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  zig_0_15,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version;
in
stdenvNoCC.mkDerivation {
  pname = "zigdoc";
  inherit version;

  src = fetchFromGitHub {
    owner = "rockorager";
    repo = "zigdoc";
    rev = "v${version}";
    hash = versionData.sourceHash;
  };

  nativeBuildInputs = [ zig_0_15 ];

  patches = [ ./remove-ziglint.patch ];

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
