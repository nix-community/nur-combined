{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-niri-workspaces";
  version = "0-unstable-2026-08-04";

  src = fetchFromGitHub {
    owner = "Embers-of-the-Fire";
    repo = "dank-niri-workspaces";
    rev = "c6699c6a2cfc8f6a3f22f6ea6b3bee9e2d43d582";
    hash = "sha256-pxkZkl1hylRKVwswodpBjlJTege7mnvfkG11j28js2Q=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell launcher plugin to search and switch to Niri workspaces by name";
    homepage = "https://github.com/Embers-of-the-Fire/dank-niri-workspaces";
    license = with licenses; [ mit asl20 ];
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
