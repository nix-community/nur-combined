{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation 
{
  name = "my-cursor";
  src = fetchFromGitHub 
  {
    owner = "dan4ik605743";
    repo = "lyra-cursors";
    rev = "cd609236710ef6152592bb0b6348f7de30512309";
    sha256 = "137l6kfl46x1p096f17hxpnxv74mji01bm156llfm5470vzmj5dc";
  };
  installPhase = 
  ''
    install -dm 755 $out/share/icons
    cp -dr --no-preserve='ownership' Lyra{B,F,G,P,Q,X}-cursors $out/share/icons/
  '';
  meta = with lib; {
    description = "This is an x-cursor theme inspired by macOS and based on capitaine-cursors";
    homepage = "https://github.com/yeyushengfan258/Lyra-Cursors";
    license = licenses.mit;
  };
}
