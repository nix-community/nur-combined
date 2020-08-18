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
    rev = "c9b5873cba2f373abea8dd610b1ee873cda45b26";
    sha256 = "08nwnsjb34k7rqlva2h0czpzkbzxpgsl050pix3gmy06m0kn9zdl";
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
