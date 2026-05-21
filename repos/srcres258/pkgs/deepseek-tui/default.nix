{
  maintainers,
  pkgs,
  ...
}: let
  pname = "deepseek-tui";
  version = "0.8.39";
in pkgs.rustPlatform.buildRustPackage {
  inherit pname version;

  src = pkgs.fetchFromGitHub {
    owner = "Hmbown";
    repo = "DeepSeek-TUI";
    rev = "v${version}";
    hash = "sha256-CpJ+98frA09F5KRzj5FSy2xZ5EfQJx4FdRiVc7HhDF8=";
  };

  cargoHash = "sha256-VAZusLxuEieCTb+afiQmPejE7gVJC9hBSNr0icRhMMQ=";

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
    broken = versionOlder pkgs.rustc.version "1.88.0";
  };
}
