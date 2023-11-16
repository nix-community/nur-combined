{ lib, stdenv
, allegro5
, cmake
, fetchFromGitLab
, libGL
, libwebp
, xorg
}:
let
  allegro' = allegro5.overrideAttrs (base: {
    # TODO: patch upstream nixpkgs' allegro5 to have this enabled
    buildInputs = base.buildInputs ++ [
      libwebp
    ];
  });
in stdenv.mkDerivation rec {
  pname = "animatch";
  version = "1.0.3";
  src = fetchFromGitLab {
    owner = "HolyPangolin";
    repo = "animatch";
    fetchSubmodules = true;
    rev = "v${version}";
    hash = "sha256-zBV45WMAXtCpPPbDpr04K/a9UtZ4KLP9nUauBlbhrFo=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    allegro'
    libGL
    xorg.libX11
  ];

  cmakeFlags = [
    "-DLIBSUPERDERPY_STATIC=ON"  # recommended by upstream for coexistence with other superderpy games
  ];

  # debugging:
  # NIX_CFLAGS_COMPILE = "-Og -ggdb";
  # dontStrip = true;
  #
  # run with:
  # SDL_VIDEODRIVER=wayland animatch --debug --windowed
  meta = {
    homepage = "https://gitlab.com/HolyPangolin/animatch/";
    description = "a match-three game with cute animals";
    longDescription = ''
      The game was made for [Purism, SPC](https://puri.sm/)
      by [Holy Pangolin](https://holypangolin.com/) studio,
      consisting of [Agata Nawrot](https://agatanawrot.com/)
      and [Sebastian Krzyszkowiak](https://dosowisko.net/).
    '';
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
