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
}:
stdenv.mkDerivation {

  pname = "instantWallpaper";
  version = "unstable";

  srcs = [
    (fetchFromGitHub {
      owner = "instantOS";
      repo = "instantWALLPAPER";
      rev = "2ff6eb814227b183a38a9784d681895625618c65";
      sha256 = "1xcn1iicfyq365qm5mrb3236gm6d2vxy9dkjdl9j0d89adgjf26b";
      name = "instantOS_instantWallpaper";
    }) 
    (fetchFromGitHub {
      owner = "instantOS";
      repo = "instantLOGO";
      rev = "ae4626d6e67d078657389c290db8c29d234f8250";
      sha256 = "1909ikrkzg3wp4g8868c0m03bg1r3rnyzz2n4rd6kkr7s9vwz2ac";
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
  ];

  postPatch = ''
    substituteInPlace wall.sh \
      --replace /usr/share/backgrounds/readme.jpg ${instantLogo}/share/backgrounds/readme.jpg \
      --replace /usr/share/instantwallpaper/wallutils.sh wallutils.sh \
      --replace "/usr/share/paperbash" "${Paperbash}/share/paperbash" \
      --replace wallutils.sh "$out/share/instantwallpaper/wallutils.sh"
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
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
