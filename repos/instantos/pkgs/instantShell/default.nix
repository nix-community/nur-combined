{ lib
, stdenv
, fetchFromGitHub
, sqlite
}:
stdenv.mkDerivation {

  pname = "instantShell";
  version = "unstable";

  srcs = [ 
    (fetchFromGitHub {
      owner = "instantOS";
      repo = "instantshell";
      rev = "a3348b1cc73deeea4fcdb7bdf7ae7ae15bc514cb";
      sha256 = "Z3Hy+cXY7aOND3MrAGeyGNwVMFXXccDr6q/PStiKUtE=";
      name = "instantOS_instantShell";
    })
    (fetchFromGitHub {
      owner = "ohmyzsh";
      repo = "ohmyzsh";
      rev = "0ab87c26c17171ae6162ff379a0c704fa57dff2e";
      sha256 = "HLWLYYcC+SoJAn8KpzSAVHrLh61N3jieHmadeSQ/zuc=";
      name = "ohmyzsh";
    })
  ];

  sourceRoot = ".";

  dontBuild = true;

  makeFlags = [ "PREFIX=$(out)" ];

  postPatch = ''
    ls -lh
    cat instantOS_instantShell/zshrc >> ohmyzsh/templates/zshrc.zsh-template
    rm instantOS_instantShell/zshrc
  '';

  installPhase = ''
    install -Dm 755 instantOS_instantShell/instantshell.sh "$out/bin/instantshell"
    install -Dm 644 instantOS_instantShell/instantos.plugin.zsh $out/share/instantshell/custom/plugins/instantos/instantos.plugin.zsh
    install -Dm 644 instantOS_instantShell/instantos.zsh-theme $out/share/instantshell/custom/themes/instantos.zsh-theme
    install -Dm 644 instantOS_instantShell/zshrc $out/share/instantshell/zshrc || true
    cp -r ohmyzsh/* $out/share/instantshell
  '';

  meta = with lib; {
    description = "instantOS Shell";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantshell";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
