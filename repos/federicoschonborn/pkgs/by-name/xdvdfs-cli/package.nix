{
  lib,
  rustPlatform,
  fetchFromGitHub,
  versionCheckHook,
  nix-update-script,
}:

let
  version = "0.8.3";
in

rustPlatform.buildRustPackage {
  pname = "xdvdfs-cli";
  inherit version;

  src = fetchFromGitHub {
    owner = "antangelo";
    repo = "xdvdfs";
    rev = "v${version}";
    hash = "sha256-58f9eznPKeUVnUvslcm0CQPC+1xU3Zto+R56IXPBKT4=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-vNCqfXsPjb3mph28YuYKpWTs9VHbIcXs6GVn4XgQKtQ=";

  cargoBuildFlags = [ "--package xdvdfs-cli" ];
  cargoTestFlags = [ "--package xdvdfs-cli" ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/xdvdfs";
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "xdvdfs-cli";
    description = "Original Xbox DVD Filesystem library and management tool";
    homepage = "https://github.com/antangelo/xdvdfs";
    changelog = "https://github.com/antangelo/xdvdfs/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
