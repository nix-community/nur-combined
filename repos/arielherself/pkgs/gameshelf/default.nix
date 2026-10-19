{ lib
, rustPlatform
, fetchFromGitHub
, makeWrapper
, umu-launcher
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gameshelf";
  version = "0.1.0-unstable-2026-10-11";

  src = fetchFromGitHub {
    owner = "arielherself";
    repo = "gameshelf";
    rev = "681feccbc47191c4d1325cbba7c03f79f72349bc";
    hash = "sha256-fVVVamOAQ0OkRYVwaoyuDb2RyAQGiyG/MUuotCa0GIY=";
  };

  cargoHash = "sha256-Q2ZtHkvbhgzoNGmadJAiiVNYVTb/xW5StUiCbUo4Ydo=";

  nativeBuildInputs = [ makeWrapper ];

  # Upstream's flake takes umu-launcher from umu's own flake, which NUR cannot
  # evaluate; nixpkgs' build fills the same role. Appended, not prepended: a
  # umu-run installed by the host distro wins, since Nix's runs games in an FHS
  # sandbox that only finds GPU drivers via /run/opengl-driver, i.e. on NixOS.
  postInstall = ''
    wrapProgram $out/bin/gameshelf \
      --suffix PATH : ${lib.makeBinPath [ umu-launcher ]}
  '';

  meta = {
    description = "TUI game launcher for Windows games on Linux via umu-launcher and Proton";
    homepage = "https://github.com/arielherself/gameshelf";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [
      {
        name = "arielherself";
        github = "arielherself";
        githubId = 107245128;
      }
    ];
    mainProgram = "gameshelf";
    platforms = lib.platforms.linux;
  };
})
