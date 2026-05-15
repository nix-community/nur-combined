{
  maintainers,
  pkgs,
  ...
}: let
  pname = "deepseek-tui";
  version = "0.8.37";
in pkgs.rustPlatform.buildRustPackage {
  inherit pname version;

  src = pkgs.fetchFromGitHub {
    owner = "Hmbown";
    repo = "DeepSeek-TUI";
    rev = "v${version}";
    hash = "sha256-mSSnTSSlmnDeKXGh+O8Qvg8th6W2ML4oCVcSvcEDwZs=";
  };

  cargoHash = "sha256-0BeUs+a2nk5DhSfNJWmdQBTDjlrtsdXR+/nzQbe+6ec=";

  nativeBuildInputs = with pkgs; [
    pkg-config
  ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
    pkgs.autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    openssl
  ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
    dbus.dev
    dbus.lib
    stdenv.cc.cc.lib
  ];

  doCheck = false;

  cargoBuildFlags = [
    "--package" "deepseek-tui-cli"
    "--package" "deepseek-tui"
  ];

  meta = with pkgs.lib; {
    description = "Coding agent for DeepSeek models that runs in your terminal";
    homepage = "https://github.com/Hmbown/DeepSeek-TUI";
    license = licenses.mit;
    maintainers = with maintainers; [ srcres258 ];
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "deepseek";
  };
}
