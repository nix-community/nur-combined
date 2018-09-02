self: super:

(super.sway.overrideDerivation (old: {
  name = "sway-0.15-rc3";
  src = super.fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = "7c3b0ffc324d913dd1c58b2497c9c36c74580ded";
    sha256 = "0x3ffb28ycg4w4k9i8jlnllwgkz8fwqr3xnf899giqcvm4mnz021";
  };
  enableParallelBuilding = true;
})).override { wlc = self.wlc; }
