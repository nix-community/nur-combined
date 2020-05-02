extension:
{ lib, rustPlatform, buildPackages, fetchFromGitHub
} @ args:

rustPlatform.buildRustPackage (let super = {
  pname = "uniconize";
  # version = ...;

  srcFunction = fetchFromGitHub;
  src = {
    owner = "neXromancers";
    repo = "uniconize";
    rev = "v${self.version}";
    # sha256 = ...;
  };

  # cargoSha256 = ...;

  nativeBuildInputs = [
    buildPackages.python3
  ];

  meta = with lib; {
    description = "A workaround for Wine games blackscreening on sway";
    longDescription = ''
      This a is fix for Wine games blackscreening on sway and other tiling
      window managers that don't support iconized windows.

      i3 and sway are tiling window managers and do not support iconized
      windows by design. Unfortunately for them, the ICCCM standard says that
      they must. That said, for native applications, it's fine to ignore
      iconization requests because, by X11 convention, state will not change
      until the window manager says so.

      However, Windows applications running in Wine are more problematic. On
      Windows, when the application sets the iconized flag, the window is
      guaranteed to be iconized, without any feedback from the window manager.
      Wine can therefore not conform to the convention, and can only blindly
      assume that the application has been iconized.

      This is a problem on i3 and sway, as because they do not support such a
      state, they have no mechanism to bring a client back from it. And since
      focusing out of a fullscreen window will immediately iconize it on
      Windows, games tend to get stuck into that state pretty easily.

      As it turns out though, it is sufficient to tell the game that it's been
      uniconized to bring it back from the dead, without resorting to Wine's
      virtual desktop. i3 already includes this behavior, but fixing this in
      sway appears more complicated, so I've opted to write this little
      program instead.
    '';
    homepage = "https://github.com/neXromancers/uniconize";
    license = licenses.mpl20;
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.unix;
  };
}; self = super // extension args self super;
in builtins.removeAttrs self [ "srcFunction" ] // {
  src = self.srcFunction self.src;
})
