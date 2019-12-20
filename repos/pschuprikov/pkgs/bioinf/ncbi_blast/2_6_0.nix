import ./generic.nix {
  version = "2.6.0";
  sha256 = "sha256:15n937pw5aqmyfjb6l387d18grqbb96l63d5xj4l7yyh0zbf2405";
  postPatch = ''
    substituteInPlace ./src/build-system/configure \
      --replace "PATH='/bin:/usr/bin:\\\$PATH'" 'PATH="/bin:/usr/bin:\$PATH"'
  '';

  patches = [ ./install-fix.patch ];
}
