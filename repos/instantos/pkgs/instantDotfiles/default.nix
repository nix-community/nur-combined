{ lib
, stdenv
, fetchFromGitHub
, instantConf
, instantWALLPAPER
}:
stdenv.mkDerivation rec {

  pname = "instantDotfiles";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "paperbenni";
    repo = "dotfiles";
    rev = "ac679449e2d4bff06ced1ac3e144f0bd1228f67c";
    sha256 = "05kzzsn687vcxy2aq87padrn9c2qppx6zxwk1bk96hfvbyk09gh8";
  };

  patches = [ ./fix-absolute-paths.patch ];

  postPatch = ''
    substituteInPlace instantdotfiles \
      --replace iconf "${instantConf}/bin/iconf" \
      --replace "/usr/share/instantdotfiles/versionhash" "$out/share/instantdotfiles/versionhash" \
      --replace "/usr/share/instantdotfiles" "$out/share/instantdotfiles"
    substituteInPlace userinstall.sh \
      --replace iconf "${instantConf}/bin/iconf" \
      --replace "/usr/share/instantdotfiles" "$out/share/instantdotfiles"
    substituteInPlace neofetch.conf \
      --replace "/usr/share/instantwallpaper" "${instantWALLPAPER}/share/instantwallpaper"
  '';
  
  installPhase = ''
    mkdir -p $out/share/instantdotfiles
    install -Dm 555 instantdotfiles $out/bin/instantdotfiles
    rm instantdotfiles
    mv * $out/share/instantdotfiles
    echo "6081b26" > $out/share/instantdotfiles/versionhash
  '';

  propagatedBuildInputs = [ instantConf instantWALLPAPER ];

  meta = with lib; {
    description = "instantOS dotfiles";
    license = licenses.mit;
    homepage = "https://github.com/paperbenni/dotfiles";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
