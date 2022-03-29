{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, instantLogo
, instantConf
, instantUtils
, Paperbash
, imagemagick
, nitrogen
, xdg-user-dirs
, zenity
}:
stdenv.mkDerivation {

  pname = "instantWallpaper";
  version = "unstable";

  srcs = [
    (fetchFromGitHub {
      owner = "instantOS";
      repo = "instantWALLPAPER";
      rev = "95a2c6a828cbfe9df7c6e7ef2c0c40abc7b2ef82";
      sha256 = "w8wKOF3quKBvCFuh85mkkosRNsm1zwba13ZiWPsZ9gg=";
      name = "instantOS_instantWallpaper";
    }) 
    (fetchFromGitHub {
      owner = "instantOS";
      repo = "instantLOGO";
      rev = "014673c0d7cc62a35b639bb308f23d2c8d8b74a5";
      sha256 = "Bu/z06GxwFQy+oB+rHeWi6SZgpkf4r7TgXx8S0djvDM=";
      name = "instantOS_instantLogo";
    })
  ];

  sourceRoot = "instantOS_instantWallpaper";

  patches = [ ./set-instantix-overlay.patch ];

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = [
    instantConf
    instantLogo
    instantUtils
    Paperbash
    imagemagick
    nitrogen
    xdg-user-dirs
    zenity
  ];

  postPatch = ''
    substituteInPlace wall.sh \
      --replace /usr/share/backgrounds/readme.jpg ${instantLogo}/share/backgrounds/readme.jpg \
      --replace /usr/share/instantwallpaper/wallutils.sh wallutils.sh \
      --replace "/usr/share/paperbash" "${Paperbash}/share/paperbash" \
      --replace wallutils.sh "$out/share/instantwallpaper/wallutils.sh"
    substituteInPlace wallutils.sh \
      --replace 'zenity' "${zenity}/bin/zenity"
    patchShebangs *.sh
  '';

  installPhase = ''
    install -Dm 555 wallutils.sh "$out/share/instantwallpaper/wallutils.sh"
    install -Dm 555 wall.sh "$out/bin/instantwallpaper"
    install -Dm 644 ../instantOS_instantLogo/wallpaper/defaultwall.png "$out/share/backgrounds/instant.png"
    install -Dm 644 ../instantOS_instantLogo/wallpaper/readme.jpg "$out/share/backgrounds/readme.jpg"
    install -Dm 644 ../instantOS_instantLogo/ascii.txt "$out/share/instantwallpaper/ascii.txt"
    install -Dm 644 ../instantOS_instantLogo/wallpaper/defaultphoto.png "$out/share/instantwallpaper/defaultphoto.png"
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram "$out/bin/instantwallpaper" \
      --prefix PATH : ${lib.makeBinPath [ instantConf instantUtils nitrogen ]}
    # wrapProgram "$out/share/instantwallpaper/wallutils.sh" \
    #   --prefix PATH : ${lib.makeBinPath [ instantConf instantUtils imagemagick ]}
    #   --prefix PATH : ${lib.makeBinPath [ instantConf instantUtils imagemagick ]}
    sed -i '2s|^|export\ PATH="${lib.makeBinPath [ instantConf instantUtils imagemagick ]}"\$\{PATH:\+\":\"\}\$PATH|' "$out/share/instantwallpaper/wallutils.sh" 
  '';

  meta = with lib; {
    description = "Wallpaper manager of instantOS";
    license = licenses.gpl2;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
