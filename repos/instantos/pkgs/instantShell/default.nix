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
      rev = "2fcc83fea4c71b7537ca8b5ed3c0ea7147d79405";
      sha256 = "0iagkp0xpm0bbf3ajngwc8azhw7g97qkwg5q4wii6y7xibj958f0";
      name = "instantshell";
    })
    (fetchFromGitHub {
      owner = "ohmyzsh";
      repo = "ohmyzsh";
      rev = "7deaff71a2be08145d83f0177edbf2dfb3e91262";
      sha256 = "1xprm8wdyk1cb02mpl7dmnlxliww8v05nigb7qpgbxn42rww7891";
      name = "ohmyzsh";
    })
  ];

  sourceRoot = ".";

  postPatch = ''
    ls -lh
    cat instantshell/zshrc >> ohmyzsh/templates/zshrc.zsh-template
    rm instantshell/zshrc
  '';

  installPhase = ''
    install -Dm 644 instantshell/instantos.plugin.zsh $out/share/instantshell/custom/plugins/instantos/instantos.plugin.zsh
    install -Dm 644 instantshell/instantos.zsh-theme $out/share/instantshell/custom/themes/instantos.zsh-theme
    install -Dm 555 instantshell/install.sh $out/bin/instantshell
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
