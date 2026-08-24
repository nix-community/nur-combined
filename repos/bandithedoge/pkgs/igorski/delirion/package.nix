{ fetchFromGitHub, igorski }:
igorski.mkJuce (finalAttrs: {
  pname = "delirion";
  version = "1.1.0";
  src = fetchFromGitHub {
    owner = "igorski";
    repo = "delirion";
    rev = finalAttrs.version;
    hash = "sha256-87+9N/CLKuhh+suwUi/y9EVbP2aFqU9ydbjMKp4jE5c=";
  };

  patches = [ ./delirion-cmake.patch ];

  meta = {
    description = "A multiband Doppler-based chorusing/detune effect";
    homepage = "https://www.igorski.nl/download/delirion";
  };
})
