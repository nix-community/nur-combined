{ lib
, stdenv
, fetchFromGitHub
, instantConf
, instantWallpaper
}:
let
  rev = "84aadb3b36c9a2d07d5dfb646c1e2dae974df442";
in
stdenv.mkDerivation {

  pname = "instantDotfiles";
  version = "unstable";

  src = fetchFromGitHub {
    inherit rev;
    owner = "instantOS";
    repo = "dotfiles";
    sha256 = "1bb9n4ir6cxkfd5h4zqsmb7x6nzfscd4m4q9qn5c7a01lmh27iac";
    name = "instantOS_instantDotfiles";
  };

  postPatch = ''
    substituteInPlace rootconfig/lightdm-gtk-greeter.conf \
      --replace "/usr/share/instantwallpaper" "${instantWallpaper}/share/instantwallpaper"
  '';
  
  installPhase = ''
    mkdir -p "$out/share/instantdotfiles"
    echo "${lib.substring 0 7 rev}" > $out/share/instantdotfiles/versionhash
    install -m644 -D LICENSE "$out/share/licenses/instantdotfiles/LICENSE"
    mv * "$out/share/instantdotfiles"
  '';

  propagatedBuildInputs = [ instantConf instantWallpaper ];

  meta = with lib; {
    description = "instantOS dotfiles";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/dotfiles";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
