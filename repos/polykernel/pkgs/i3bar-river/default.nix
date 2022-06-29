{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, pango
, makeWrapper
, wayland
, wayland-scanner
}:

rustPlatform.buildRustPackage rec {
  pname = "i3bar-river";
  version = "master";

  src = fetchFromGitHub {
    owner = "MaxVerevkin";
    repo = pname;
    rev = "c8fd8516e20eb5600abecf621c47f8ab7f26e562";
    sha256 = "sha256-tBwsguqbCuTii1rTvqHzdYlUISFK6y5AKM6WrHXkHQQ=";
  };

  cargoHash = "sha256-5kF9buxQYWugy+iBXcAR2hBNbBNL4HqBUkVeuUCc7yc=";

  nativeBuildInputs = [ wayland-scanner makeWrapper pkg-config ];

  buildInputs = [ pango ];

  postInstall = ''
    wrapProgram "$out/bin/i3bar-river" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ wayland ]}"
  '';

  meta = with lib; {
    description = "A port of i3bar for river.";
    homepage = "https://github.com/MaxVerevkin/i3bar-river";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.polykernel ];
    platforms = platforms.linux;
  };
}
