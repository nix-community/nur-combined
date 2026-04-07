{
  maintainers,
  pkgs,
  ...
}: let
  pname = "keystroke";
  version = "0.1.0";
  src = pkgs.fetchFromGitHub {
    owner = "kfurafaelss";
    repo = pname;
    rev = "cbb059f28e4db3ef518315432af693d634c0bc21";
    sha256 = "sha256-EOuIzUble+26CZsIUVci0dVh3honYnA5W8GsomlRmcU=";
  };
  runtimeDeps = with pkgs; [
    gtk4
    gtk4-layer-shell
    libinput
    wayland
    wayland-protocols
    dbus
    libappindicator-gtk3
    libxkbcommon
  ];
in pkgs.rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = "sha256-q2P83RG+tHkego2gRIZhT4aGqAWNivxLnCrasxGfhOM=";

  nativeBuildInputs = with pkgs; [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = runtimeDeps;
  doCheck = false;

  postPatch = ''
    substituteInPlace src/tray.rs \
      --replace-fail '!x.is_multiple_of(3)' 'x % 3 != 0'
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath runtimeDeps}"
    )
  '';

  meta = with pkgs.lib; {
    description = "Display your keyboard and mouse activity in real-time";
    homepage = "https://github.com/kfurafaelss/keystroke";
    license = licenses.mit;
    maintainers = [ maintainers.srcres258 ];
    mainProgram = "keystroke";
    platforms = platforms.linux;
  };
}
