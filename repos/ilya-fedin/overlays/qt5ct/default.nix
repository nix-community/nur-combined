self: super:

{
  libsForQt5 = super.libsForQt5.overrideScope' (_: _: {
    qt5ct = (import ../.. { pkgs = super; }).qt5ct;
  });
}
