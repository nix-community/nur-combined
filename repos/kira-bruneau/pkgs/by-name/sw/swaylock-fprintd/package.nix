{
  swaylock,
  fetchFromGitHub,
  substituteAll,
  fprintd,
  dbus,
  unstableGitUpdater,
}:

swaylock.overrideAttrs (attrs: {
  pname = "swaylock-fprintd";
  version = "0-unstable-2023-01-30";

  src = fetchFromGitHub {
    owner = "SL-RU";
    repo = "swaylock-fprintd";
    rev = "ffd639a785df0b9f39e9a4d77b7c0d7ba0b8ef79";
    hash = "sha256-2VklrbolUV00djPt+ngUyU+YMnJLAHhD+CLZD1wH4ww=";
  };

  patches = [
    (substituteAll {
      src = ./fprintd.patch;
      inherit fprintd;
    })
  ];

  buildInputs = attrs.buildInputs ++ [
    dbus
    fprintd
  ];

  pos = __curPos;
  passthru.updateScript = unstableGitUpdater { };
})
