{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "cortile";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "leukipp";
    repo = "cortile";
    rev = "v${version}";
    hash = "sha256-bOIG8O5cw0CJ096KoePSgwRq+aP88EHs7s2hoqOL2Xc=";
  };

  vendorHash = "sha256-As7t/LJcqqGTT5QRK+DocnIRV9gmvSDOs0u0yGq2T7M=";

  ldflags = [
    "-s"
    "-w"
    "-X=main.name=cortile"
    "-X=main.version=${version}"
    "-X=main.commit=${src.rev}"
    "-X=main.date=1970-01-01T00:00:00Z"
  ];

  meta = with lib; {
    description = "Linux auto tiling manager with hot corner support for Openbox, Fluxbox, IceWM, Xfwm, KWin, Marco, Muffin, Mutter and other EWMH compliant window managers using the X11 window system. Therefore, this project provides dynamic tiling for XFCE, LXDE, LXQt, KDE and GNOME (Mate, Deepin, Cinnamon, Budgie) based desktop environments";
    homepage = "https://github.com/leukipp/cortile";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "cortile";
  };
}
