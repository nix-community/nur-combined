{
  pkgs,
  nurLib,
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

let
  src = fetchFromGitHub {
    owner = "thanhdat77";
    repo = "herdr-navigator";
    rev = "v0.3.6";
    hash = "sha256-+xtBu4m2YenFH+W3Sv7atDvcsgChS5mKXgVgKomM768=";
  };

  meta = {
    description = "Jump to any Herdr workspace, agent, project, session, remote, directory, or action from one fuzzy navigator.";
    mainProgram = "herdr-navigator";
    homepage = "https://github.com/thanhdat77/herdr-navigator";
    license = [
      pkgs.lib.licenses.mit
    ];
  };

  package = nurLib.crate2nix {
    inherit src;
    pname = "herdr-navigator";
    resolvedJson = ./Cargo.json;

    inherit meta;
  };
in
stdenvNoCC.mkDerivation {
  inherit src;
  pname = package.pname;
  version = package.version;

  buildPhase = ''
    # Replace './target/release/herdr-navigator' with the path to the binary in the package
    sed 's|./target/release/herdr-navigator|./bin/herdr-navigator|' $src/herdr-plugin.toml >herdr-plugin.toml
  '';

  installPhase = ''
    mkdir -p $out/libexec/herdr/plugins/herdr-navigator/
    install -Dm644 herdr-plugin.toml $out/libexec/herdr/plugins/herdr-navigator/herdr-plugin.toml
    ln -s ${package}/bin $out/libexec/herdr/plugins/herdr-navigator/bin
  '';

  passthru = {
    inherit (package) updateScript;
  };

  meta = meta // {
    herdr.plugin.id = "herdr-navigator";
  };
}
