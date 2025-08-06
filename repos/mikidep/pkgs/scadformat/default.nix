{
  fetchFromGitHub,
  writeShellScriptBin,
  buildGoModule,
  antlr4,
  lib,
}:
buildGoModule rec {
  pname = "scadformat";
  version = "v0.9";

  src = fetchFromGitHub {
    owner = "hugheaves";
    repo = "scadformat";
    rev = version;
    hash = "sha256-X8STNxywwu3AirR0yrVGaduIU/P9ryJoLJXeBp64qJs=";
  };
  vendorHash = "sha256-HOjfKFDG4otwu5TGXNtQCBQ7PURtPoeN8M8+uVHn5+4=";

  nativeBuildInputs = [
    antlr4
    (
      writeShellScriptBin "git" ''
        echo "${version}"
      ''
    )
  ];
  preBuild = ''
    go generate ./...
  '';
  subPackages = [
    "cmd/scadformat.go"
  ];
  meta = with lib; {
    mainProgram = "scadformat";
    description = "A source code formatter / beautifier for OpenSCAD.";
    homepage = "https://github.com/hugheaves/scadformat";
    license = licenses.gpl2;
    platforms = platforms.all;
  };
}
