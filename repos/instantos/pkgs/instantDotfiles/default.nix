{ lib
, stdenv
, fetchFromGitHub
, instantConf
, instantWallpaper
}:
stdenv.mkDerivation {

  pname = "instantDotfiles";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "paperbenni";
    repo = "dotfiles";
    rev = "4beacaa4521cd88f58a28117c3fc8384e6d0ee81";
    sha256 = "1l35y1456ph9rj72hrv8mz7c6x9zy9fzvdbd67nfzvz221h233wv";
    name = "instantOS_instantDotfiles";
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
      --replace "/usr/share/instantwallpaper" "${instantWallpaper}/share/instantwallpaper"
  '';
  
  installPhase = ''
    mkdir -p $out/share/instantdotfiles
    install -Dm 555 instantdotfiles $out/bin/instantdotfiles
    rm instantdotfiles
    mv * $out/share/instantdotfiles
    echo "6081b26" > $out/share/instantdotfiles/versionhash
  '';

  propagatedBuildInputs = [ instantConf instantWallpaper ];

  meta = with lib; {
    description = "instantOS dotfiles";
    license = licenses.mit;
    homepage = "https://github.com/paperbenni/dotfiles";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
