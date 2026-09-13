{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-audio-inhibit";
  version = "0-unstable-2026-03-04";

  src = fetchFromGitHub {
    owner = "insecure";
    repo = "dms-audio-inhibit";
    rev = "eefccb20299d8d79089d3d976ca1505ae16d3e27";
    hash = "sha256-G3vBoFlixUqyaGUG6zjtAvYq95Y9eH5b4g/yZnkqCgs=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell daemon plugin that enables an idle inhibitor while audio is playing";
    homepage = "https://github.com/insecure/dms-audio-inhibit";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
