{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-todo-launcher";
  version = "0-unstable-2026-06-20";

  src = fetchFromGitHub {
    owner = "iskepr";
    repo = "DankTodoLauncher";
    rev = "a42aec0a85b662f167d48c3d8a590b0ba23e8499";
    hash = "sha256-ibS5c8zerVLkpNthcZdOd6dh7uvdr1tIa93IpLnajCE=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell simple todo list launcher plugin to manage, track, and export your daily tasks";
    homepage = "https://github.com/iskepr/DankTodoLauncher";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
