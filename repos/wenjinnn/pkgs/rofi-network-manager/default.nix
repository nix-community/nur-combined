{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  rofi-wayland,
  networkmanager,
}:
stdenv.mkDerivation {
  pname = "rofi-network-manager";
  version = "unstable-2024-09-03";

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "rofi-network-manager";
    rev = "90302dd1c0ea2d460a3455a208c10dff524469cd";
    sha256 = "sha256-D8/Lh5a5rAUOhCXbjmL65PFzgmj3uu2mwCtxakHTefM=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm 0755 network-manager.sh $out/bin/rofi-network-manager

    wrapProgram $out/bin/rofi-network-manager \
      --prefix PATH ":" ${
        lib.makeBinPath [
          rofi-wayland
          networkmanager
        ]
      }

    runHook postInstall
  '';

  meta = with lib; {
    description = "Manage wifi and ethernet with rofi.";
    homepage = "https://github.com/meowrch/rofi-network-manager";
    license = licenses.mit;
    maintainers = with maintainers; [ wenjinnn ];
    mainProgram = "rofi-network-manager";
    platforms = platforms.linux;
  };
}
