{
  maintainers,
  pkgs,
  ...
}: let
  pname = "bibox";
  version = "0.2.29";
in pkgs.rustPlatform.buildRustPackage {
  inherit pname version;

  src = pkgs.fetchFromGitHub {
    owner = "namil-k";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-46tN7NNqsy75ibFr0P2r3BLzhqYHjHovorXlO9pwtdo=";
  };

  cargoHash = "sha256-ibSZbHwtSRRoX/IXBRTAMANcOaq6J3WlwobnBOoLkIM=";

  cargoBuildFlags = [ "--ignore-rust-version" ];

  meta = with pkgs.lib; {
    description = "A TUI bibliography manager";
    homepage = "https://github.com/namil-k/${pname}";
    license = licenses.mit;
    maintainers = with maintainers; [ srcres258 ];
    platforms = platforms.linux;
    mainProgram = pname;
    broken = versionOlder pkgs.rustc.version "1.88.0";
  };
}
