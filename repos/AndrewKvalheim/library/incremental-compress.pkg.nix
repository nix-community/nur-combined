{ addBinToPathHook
, buildGoModule
, fetchFromGitHub
, lib
, unstableGitUpdater
}:

let
  inherit (lib) escapeShellArg licenses;
in
buildGoModule (incremental-compress: {
  pname = "incremental-compress";
  version = "0-unstable-2025-03-30";
  meta = {
    description = "Incremental compression tool for static page generators";
    homepage = "https://github.com/scottlaird/incremental-compress";
    license = licenses.asl20;
    mainProgram = "incremental-compress";
  };

  passthru.updateScript = unstableGitUpdater { };

  src = fetchFromGitHub {
    owner = "scottlaird";
    repo = "incremental-compress";
    rev = "30c9c0de71d5f988fe0b5fd70834c1be1088ee95";
    hash = "sha256-Qbp8ldpD81S66MBPk0Y1jM45GVnGVWoTsvS1eV+PXk0=";
  };

  vendorHash = "sha256-yh6dXS0TCcafqFe9PUokyWqg6lWEMIy6ddI4YgUtxDE=";

  doInstallCheck = true;
  installCheckInputs = [ addBinToPathHook ];
  postInstallCheck = ''
    ${escapeShellArg incremental-compress.meta.mainProgram} --help
  '';
})
