{ swaylock
, fetchFromGitHub
, substituteAll
, fprintd
, dbus
}:

swaylock.overrideAttrs (attrs: {
  version = "unstable-2023-01-30";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "swaylock";
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
})
