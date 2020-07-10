{ lib
, stdenv
, fetchFromGitHub
, instantLOGO
, instantConf
, instantUtils
, Paperbash
, imagemagick
, nitrogen
}:
stdenv.mkDerivation rec {

  pname = "instantWALLPAPER";
  version = "unstable";

  srcs = [
    (fetchFromGitHub {
      owner = "instantOS";
      repo = "instantWALLPAPER";
      rev = "39a212ed2a2560187c0125126640f0d0c06d9982";
      sha256 = "1ril747fiwg0lzz4slc9ndzy5an3mwnmqk6fk58pp09z5g2wjhla";
      name = "instantWALLPAPER";
    }) 
    (fetchFromGitHub {
      owner = "instantOS";
      repo = "instantLOGO";
      rev = "86aaccaa62abef67f40c9717860bf01beb541767";
      sha256 = "073jgqdwz01755awjx882w9i5lwwqcjzwklcwwc3kfa52rcpd9bh";
      name = "instantLOGO";
    })
  ];

  sourceRoot = "instantWALLPAPER";

  postPatch = ''
    substituteInPlace wall.sh \
      --replace /usr/share/backgrounds/readme.jpg ${instantLOGO}/share/backgrounds/readme.jpg \
      --replace /usr/share/instantwallpaper/wallutils.sh wallutils.sh \
      --replace "iconf" "${instantConf}/bin/iconf" \
      --replace "checkinternet" "${instantUtils}/bin/checkinternet" \
      --replace "/usr/share/paperbash" "${Paperbash}/share/paperbash" \
      --replace wallutils.sh "$out/share/instantwallpaper/wallutils.sh"
    substituteInPlace wallutils.sh \
      --replace "iconf" "${instantConf}/bin/iconf" \
      --replace "identify" "${imagemagick}/bin/identify" \
      --replace "convert" "${imagemagick}/bin/convert" \
      --replace "-composite" "__tmp_placeholder" \
      --replace "composite" "${imagemagick}/bin/composite" \
      --replace "__tmp_placeholder" "-composite"
  '';
  
  installPhase = ''
    install -Dm 555 wallutils.sh "$out/share/instantwallpaper/wallutils.sh"
    install -Dm 555 wall.sh "$out/bin/instantwallpaper"
    install -Dm 644 ../instantLOGO/wallpaper/defaultwall.png "$out/share/backgrounds/instant.png"
    install -Dm 644 ../instantLOGO/wallpaper/readme.jpg "$out/share/backgrounds/readme.jpg"
    install -Dm 644 ../instantLOGO/ascii.txt "$out/share/instantwallpaper/ascii.txt"
    install -Dm 644 ../instantLOGO/wallpaper/defaultphoto.png "$out/share/instantwallpaper/defaultphoto.png"
  '';

  propagatedBuildInputs = [ instantLOGO instantConf Paperbash imagemagick nitrogen ];

  meta = with lib; {
    description = "Wallpaper manager of instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
