{
  stdenv,
  lib,
  fetchFromGitHub,
  xterm,
  coreutils,
  makeWrapper,
}:
stdenv.mkDerivation rec {

  pname = "xdg-terminal-exec";
  version = "dde440874285f837ae55b433bd720642c5ad8fef";

  src = fetchFromGitHub {
    owner = "Mikilio";
    repo = "xdg-terminal-exec";
    rev = version;
    sha256 = "sha256-Hlw1dFGXFpj5qVozsI5dV9ZHhIp7MH9zENAqYCfpamk=";
  };

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    mkdir -p $out/bin
    cp xdg-terminal-exec $out/bin/xdg-terminal-exec
    wrapProgram $out/bin/xdg-terminal-exec \
      --prefix PATH : ${lib.makeBinPath [xterm coreutils]}
  '';

  meta = {
    homepage = "https://github.com/Vladimir-csp/xdg-terminal-exec";
    description = "Proposal for XDG terminal execution utility";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = [];
  };
}
