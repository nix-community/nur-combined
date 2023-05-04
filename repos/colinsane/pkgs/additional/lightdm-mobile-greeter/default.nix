{ lib
, fetchFromGitea
, gtk3
, libhandy
, lightdm
, pkgs
, linkFarm
, pkg-config
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "lightdm-mobile-greeter";
  version = "2022-10-30";

  # upstream:
  # src = fetchFromGitea {
  #   domain = "git.raatty.club";
  #   owner = "raatty";
  #   repo = "lightdm-mobile-greeter";
  #   rev = "8c8d6dfce62799307320c8c5a1f0dd5c8c18e4d3";
  #   hash = "sha256-SrAR2+An3BN/doFl/s8PcYZMUHLfVPXKZOo6ndO60nY=";
  # };
  # cargoHash = "sha256-NZ0jOkEBNa5oOydfyKm0XQB/vkAvBv9wHBbnM9egQFQ=";

  # sane dev:
  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "lightdm-mobile-greeter";
    # rev = "bd2138f630db0dfb901bc28a9b70d6be8b9879dd";
    # hash = "sha256-B3dNvnduR1pz5DedmAR8Fc/CXowR3jsyrjMUFOMizxI=";
    rev = "f3511ec71a4a1f491d759711e0bcf031e335ea70";
    hash = "sha256-U5chzm3q3vycgX1HSLf6sk6M3YoJ4CHGLKRg4ViIhu8=";
  };
  # cargoHash = "sha256-2NMXR+D/CnDhUToQmMwK2Cb2l+4/N9BrCz/lt1NZ6Wk=";
  cargoLock = {
    lockFile = ./Cargo.lock;
    # lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "light-dm-sys-0.0.1" = "sha256-91MZhbO/Or0QOt0yVAUhtorpMBBzElFg6U59mF7WB0k=";
    };
  };

  buildInputs = [
    gtk3
    # libhandy_0
    libhandy
    lightdm
  ];
  nativeBuildInputs = [
    pkg-config
  ];

  postInstall = ''
    mkdir -p $out/share/applications
    substitute lightdm-mobile-greeter.desktop \
      $out/share/applications/lightdm-mobile-greeter.desktop \
      --replace lightdm-mobile-greeter $out/bin/lightdm-mobile-greeter
  '';

  passthru.xgreeters = linkFarm "lightdm-mobile-greeter-xgreeters" [{
    path = "${pkgs.lightdm-mobile-greeter}/share/applications/lightdm-mobile-greeter.desktop";
    name = "lightdm-mobile-greeter.desktop";
  }];

  meta = with lib; {
    description = "A simple log in screen for use on touch screens.";
    homepage = "https://git.raatty.club/raatty/lightdm-mobile-greeter";
    maintainers = with maintainers; [ colinsane ];
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
