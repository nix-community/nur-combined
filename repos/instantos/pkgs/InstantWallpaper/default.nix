{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, InstantLOGO
, InstantConf
, InstantUtils
, Paperbash
, imagemagick
, nitrogen
}:
stdenv.mkDerivation rec {

  pname = "instantWALLPAPER";
  version = "unstable";

  srcs = [
    (fetchurl {
      url = "https://github.com/instantOS/instantWALLPAPER/archive/master.tar.gz";
      sha256 = "0c3np9hd3g106ph7g9ps7vgd8ygiimxzrcm02yqjk7ir6bj8p3jk";
    }) 
    (fetchFromGitHub {
      owner = "instantOS";
      repo = "instantLOGO";
      rev = "master";
      sha256 = "073jgqdwz01755awjx882w9i5lwwqcjzwklcwwc3kfa52rcpd9bh";
    })
  ];

  sourceRoot = "instantWALLPAPER-master";

  postPatch = ''
    substituteInPlace wall.sh \
      --replace /usr/share/backgrounds/readme.jpg ${InstantLOGO}/share/backgrounds/readme.jpg \
      --replace /usr/share/instantwallpaper/wallutils.sh wallutils.sh \
      --replace "iconf" "${InstantConf}/bin/iconf" \
      --replace "checkinternet" "${InstantUtils}/bin/checkinternet" \
      --replace "/usr/share/paperbash" "${Paperbash}/share/paperbash"
    substituteInPlace wallutils.sh \
      --replace "iconf" "${InstantConf}/bin/iconf" \
      --replace "identify" "${imagemagick}/bin/identify" \
      --replace "convert" "${imagemagick}/bin/convert" \
      --replace "-composite" "__tmp_placeholder" \
      --replace "composite" "${imagemagick}/bin/composite" \
      --replace "__tmp_placeholder" "-composite"
      # --replace "ifeh" "${InstantUtils}/bin/ifeh" \
  '';
  
  installPhase = ''
    install -Dm 555 wallutils.sh $out/share/instantwallpaper/wallutils.sh
    install -Dm 555 wall.sh $out/bin/instantwallpaper
    install -Dm 644 ../source/wallpaper/defaultwall.png "$out/share/backgrounds/instant.png"
    install -Dm 644 ../source/wallpaper/readme.jpg "$out/share/backgrounds/readme.jpg"
    install -Dm 644 ../source/ascii.txt "$out/share/instantwallpaper/ascii.txt"
    install -Dm 644 ../source/wallpaper/defaultphoto.png "$out/share/instantwallpaper/defaultphoto.png"
  '';

  propagatedBuildInputs = [ InstantLOGO InstantConf Paperbash imagemagick nitrogen ];

  meta = with lib; {
    description = "Wallpaper manager of instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
