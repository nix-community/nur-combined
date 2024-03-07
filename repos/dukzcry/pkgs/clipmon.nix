{ lib, rustPlatform, fetchFromSourcehut, wayland, makeWrapper }:

rustPlatform.buildRustPackage rec {
  pname = "clipmon";
  version = "2022-08-28";

  src = fetchFromSourcehut {
    owner = "~whynothugo";
    repo = "clipmon";
    rev = "2e338fdc2841c3b2de9271d90fcceceda9e45d29";
    hash = "sha256-bEMgJYz3e2xwMO084bmCT1oZImcmO3xH6rIsjvAxnTA=";
  };

  cargoHash = "sha256-XyWpuLCYGaKbBQaue7/vPZLdSvKm03+FGkY8IDeU+Bk=";

  nativeBuildInputs = [ makeWrapper ];

  preFixup = ''
    wrapProgram $out/bin/clipmon \
      --prefix LD_LIBRARY_PATH ":" "${lib.makeLibraryPath [ wayland ]}";
  '';

  meta = with lib; {
    description = "A clipboard monitor for Wayland";
    homepage = "https://git.sr.ht/~whynothugo/clipmon";
    license = licenses.isc;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}