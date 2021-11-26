{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "Lyra-Cursors-Bin";

  src = fetchFromGitHub {
    owner = "dan4ik605743";
    repo = name;
    rev = "13ddd5b57c4212c7711c6b4a5a19dc8b6cd2c5dc";
    sha256 = "1p57kcabzin31df4x49pqnjm0wmn7yyc6b3x9ygv6xi6qizi4akj";
  };

  installPhase = ''
    install -dm 755 $out/share/icons
    cp -dr --no-preserve='ownership' Lyra{B,F,G,P,Q,R,S,X,Y}-cursors $out/share/icons/
  '';

  meta = with lib; {
    description = "This is an x-cursor theme inspired by macOS and based on capitaine-cursors";
    homepage = "https://github.com/yeyushengfan258/Lyra-Cursors";
    license = licenses.mit;
    maintainers = with maintainers; [ dan4ik605743 ];
    platforms = platforms.linux;
  };
}
