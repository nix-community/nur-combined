{ lib
, stdenv
, fetchFromGitHub
, instantLogo
, instantConf
, instantUtils
, Paperbash
, imagemagick
, nitrogen
}:
stdenv.mkDerivation {

  pname = "instantWallpaper";
  version = "unstable";

  srcs = [
    (fetchFromGitHub {
      owner = "instantOS";
      repo = "instantWALLPAPER";
      rev = "517cae5636f23dee691b799dd56d11bfd2acc573";
      sha256 = "1yqsy588fjqj07yill34w1mmcr6xjwhdmx6miv0mv0lwp8vxj2cx";
      name = "instantOS_instantWallpaper";
    }) 
    (fetchFromGitHub {
      owner = "instantOS";
      repo = "instantLOGO";
      rev = "957655938d4d393d60f237666cc3b8a6d7334df3";
      sha256 = "0m3w2c0c7bw2k3q742ncp40h9acxb8q00aj564hs440a6yx48skc";
      name = "instantOS_instantLogo";
    })
  ];

  sourceRoot = "instantOS_instantWallpaper";

  postPatch = ''
    substituteInPlace wall.sh \
      --replace /usr/share/backgrounds/readme.jpg ${instantLogo}/share/backgrounds/readme.jpg \
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
    install -Dm 644 ../instantOS_instantLogo/wallpaper/defaultwall.png "$out/share/backgrounds/instant.png"
    install -Dm 644 ../instantOS_instantLogo/wallpaper/readme.jpg "$out/share/backgrounds/readme.jpg"
    install -Dm 644 ../instantOS_instantLogo/ascii.txt "$out/share/instantwallpaper/ascii.txt"
    install -Dm 644 ../instantOS_instantLogo/wallpaper/defaultphoto.png "$out/share/instantwallpaper/defaultphoto.png"
  '';

  propagatedBuildInputs = [ instantLogo instantConf Paperbash imagemagick nitrogen ];

  meta = with lib; {
    description = "Wallpaper manager of instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
