{
  lib,
  fetchurl,
  space-cadet-pinball,
  unzip,
  ...
}: let
  fullTilt = fetchurl {
    url = "https://archive.org/download/win311_ftiltpball/FULLTILT.ZIP";
    sha256 = "16a5gd698yd3p17y3399lrz86ry9nwbvha1r82cj2gsvhqcj4fhq";
  };
in
  space-cadet-pinball.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [unzip];

    postInstall =
      (old.postInstall or "")
      + ''
        unzip ${fullTilt}
        cp -r CADET/CADET.DAT CADET/SOUND $out/lib/SpaceCadetPinball/
      '';

    meta =
      old.meta
      // {
        description = old.meta.description + " (With Full Tilt Pinball data)";
      };
  })
