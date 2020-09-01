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
      rev = "c395441dc1eeb0ea8e9b504e057fb289bb6379c5";
      sha256 = "0mqnfpv8g5cx01r0lfbfl441srma36b87iyyrp9v7fp2hvsbgswd";
      name = "instantOS_instantShell";
    })
    (fetchFromGitHub {
      owner = "ohmyzsh";
      repo = "ohmyzsh";
      rev = "a7f5170d68c0b75a9864763a90ac11e51ec67c81";
      sha256 = "03k1918cakqmg3x7kkiffdz1zwd86bipypkfigq3pgalh5zkyny9";
      name = "ohmyzsh";
    })
  ];

  sourceRoot = ".";

  postPatch = ''
    ls -lh
    substituteInPlace instantOS_instantShell/install.sh \
      --replace "/usr/share/" "$out/share/"
    cat instantOS_instantShell/zshrc >> ohmyzsh/templates/zshrc.zsh-template
    rm instantOS_instantShell/zshrc
  '';

  installPhase = ''
    install -Dm 644 instantOS_instantShell/instantos.plugin.zsh $out/share/instantshell/custom/plugins/instantos/instantos.plugin.zsh
    install -Dm 644 instantOS_instantShell/instantos.zsh-theme $out/share/instantshell/custom/themes/instantos.zsh-theme
    install -Dm 555 instantOS_instantShell/install.sh $out/bin/instantshell
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
