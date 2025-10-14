# Inspired by pkgs/applications/editors/uivonim/default.nix
# and pkgs/by-name/in/indiepass-desktop/package.nix
{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  electron_36,
  makeBinaryWrapper,
}:
buildNpmPackage rec {
  pname = "bloodhound-ce-desktop";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "Red-Flake";
    repo = "BloodHound-CE-Desktop";
    rev = "v${version}"; # Use a tag or commit hash for reproducibility
    sha256 = "sha256-Qz3zAfIY7c6K0lNwRwSFtXMJDy6dMwctHGxP80+A5+U="; # nix-prefetch-url --unpack https://github.com/Red-Flake/BloodHound-CE-Desktop/archive/v1.0.1.tar.gz
  };

  npmDepsHash = "sha256-/hZ4SDId28Z11YZ8+M9iM0ntWEfVcW3TEpQTSFeUBb8="; # you will get an error about mismatching hash the first time. Just copy the hash here

  # Useful for debugging, just run "nix-shell" and then "electron ."
  nativeBuildInputs = [
    makeBinaryWrapper
    electron_36 # Electron 36.6.0
  ];

  # Otherwise it will try to run a build phase (via npm build) that we don't have or need, with an error:
  # Missing script: "build"
  # This method is used in pkgs/by-name/in/indiepass-desktop/package.nix
  dontNpmBuild = true;

  # Needed, otherwise you will get an error:
  # RequestError: getaddrinfo EAI_AGAIN github.com
  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  # The node_modules/XXX is such that XXX is the "name" in package.json
  # The path might differ, for instance in electron-forge you need build/main/main.js
  postInstall = ''
    makeWrapper ${electron_36}/bin/electron $out/bin/${pname} \
      --add-flags $out/lib/node_modules/${pname}/src/main.js
  '';

  meta = with lib; {
    description = "Desktop Electron application for BloodHound-CE";
    homepage = "https://github.com/Red-Flake/BloodHound-CE-Desktop";
    license = licenses.gpl3;
    maintainers = [
      {
        github = "Mag1cByt3s";
        email = "ppeinecke@protonmail.com";
        name = "Pascal Peinecke";
      }
    ];
    platforms = platforms.linux; # Electron typically targets Linux, macOS, Windows
    mainProgram = "bloodhound-ce-desktop"; # Added for nix run
    sourceProvenance = [ sourceTypes.binaryNativeCode ]; # Added for Electron binary
    broken = false; # Set to true if the package is known to be broken
  };

}
