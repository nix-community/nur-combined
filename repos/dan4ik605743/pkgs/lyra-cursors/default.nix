{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "Lyra-Cursors-Bin";

  src = fetchFromGitHub {
    owner = "dan4ik605743";
    repo = name;
    rev = "463706ca7beba549d160e28d66e1466c5f07e065";
    sha256 = "1xs6bci89pqb6fzg7mcmlmi8isw5xv2ggwry9fj5vq0q2m3wig07";
  };

  installPhase = ''
    install -dm 755 $out/share/icons
    cp -dr --no-preserve='ownership' Lyra{B,F,G,P,Q,R,S,X}-cursors $out/share/icons/
  '';

  meta = with lib; {
    description = "This is an x-cursor theme inspired by macOS and based on capitaine-cursors";
    homepage = "https://github.com/yeyushengfan258/Lyra-Cursors";
    license = licenses.mit;
    maintainers = with maintainers; [ dan4ik605743 ];
    platforms = platforms.linux;
  };
}
