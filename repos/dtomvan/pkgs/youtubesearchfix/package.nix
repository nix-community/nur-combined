{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  zip,
}:

stdenvNoCC.mkDerivation {
  pname = "youtubesearchfix";
  version = "0-unstable-2026-01-28";

  src = fetchFromGitLab {
    owner = "phoennix";
    repo = "youtubesearchfix";
    rev = "37f3139b6819e927e9c653db03dc558769cd654e";
    hash = "sha256-o8vLgMX3tLY1r1SSlarjVIvSSfnAlwqyUSsJdlJ5wqM=";
  };

  nativeBuildInputs = [ zip ];

  dontConfigure = true;
  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
    mkdir -p "$dst"
    zip -r "$dst/MinYT@example.org.xpi" *
  '';

  meta = {
    description = "FOSS addon that eliminates all distracting search results on YouTube";
    homepage = "https://gitlab.com/phoennix/youtubesearchfix";
    license = lib.licenses.cc-by-sa-40;
    maintainers = with lib.maintainers; [ dtomvan ];
    platforms = lib.platforms.all;
  };
}
