{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, sqlite
}:
stdenv.mkDerivation rec {

  pname = "InstantShell";
  version = "unstable";

  srcs = [ 
    (fetchFromGitHub {
      owner = "instantOS";
      repo = "instantshell";
      rev = "2fcc83fea4c71b7537ca8b5ed3c0ea7147d79405";
      sha256 = "0iagkp0xpm0bbf3ajngwc8azhw7g97qkwg5q4wii6y7xibj958f0";
    })
    (fetchurl {
      url = "https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz";
      sha256 = "17743dal38fvbja6r2xhvysc43h9s306iqcfcc23i601hzf2wa5i";
    })
  ];

  sourceRoot = "source";

  # unpackPhase = ''
  #   runHook preUnpack
  #   i=1
  #   for _src in $srcs; do
  #     echo $_src
  #     # cp -r "$_src" source_$i
  #     i=$((i+1))
  #   done
  #   runHook postUnpack
  # '';

  postPatch = ''
    mv ../ohmyzsh-master ohmyzsh
    ls -lh ohmyzsh/templates
    cat zshrc >> ohmyzsh/templates/zshrc.zsh-template
    rm zshrc
  '';

  installPhase = ''
    install -Dm 644 instantos.plugin.zsh $out/share/instantshell/custom/plugins/instantos/instantos.plugin.zsh
    install -Dm 644 instantos.zsh-theme $out/share/instantshell/custom/themes/instantos.zsh-theme
    install -Dm 555 install.sh $out/bin/instantshell
    cp -r ohmyzsh/* $out/share/instantshell
  '';

  meta = with lib; {
    description = "InstantOS Shell";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantshell";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
