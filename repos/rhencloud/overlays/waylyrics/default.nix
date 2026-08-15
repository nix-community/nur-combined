_final: prev:
let
  src = prev.fetchFromGitHub {
    owner = "waylyrics";
    repo = "waylyrics";
    rev = "v0.4.0";
    hash = "sha256:08b2ciwdzn939vi6lyhgl80y1n04d6fgs9p219zdj18rwlkmwb1j";
  };
in
{
  waylyrics = prev.waylyrics.overrideAttrs (_old: {
    version = "0.4.0";
    inherit src;
    cargoDeps = prev.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-FaTm6pqDEdvHc5J5AJxZcDDYUzZovLzM++8JPC/QtfX0=";
    };
  });
}
