{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, sqlite
}:
stdenv.mkDerivation rec {

  pname = "InstantShell";
  version = "unstable";

  # srcs = [ 
  #   (fetchFromGitHub {
  #     owner = "instantOS";
  #     repo = "instantshell";
  #     rev = "master";
  #     sha256 = "0iagkp0xpm0bbf3ajngwc8azhw7g97qkwg5q4wii6y7xibj958f0";
  #   })

  #   (fetchFromGitHub {
  #     owner = "ohmyzsh";
  #     repo = "ohmyzsh";
  #     rev = "master";
  #     sha256 = "0qlwcyzrsrcmdi1fdd9a9niwf5sl8gg754l8r7p7cwzv0xq4jfpx";
  #   })
  # ];

  srcs = [ 
    (fetchFromGitHub {
      owner = "instantOS";
      repo = "instantshell";
      rev = "master";
      sha256 = "0iagkp0xpm0bbf3ajngwc8azhw7g97qkwg5q4wii6y7xibj958f0";
    })
    (fetchurl {
      url = "https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz";
      sha256 = "10vf22szmcgxj9wwiv0f4s54x0b2f0c4hbrhyifn1gs7w3nv2wpx";
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
