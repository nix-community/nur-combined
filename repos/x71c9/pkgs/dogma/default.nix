{ lib, rustPlatform, fetchFromGitHub, installShellFiles
, completion ? { enable = true; shells = [ "bash" ]; }
}:

rustPlatform.buildRustPackage rec {
  pname = "dogma";
  version = "0.2.2"; # without "v"

  # Pin the source to an immutable tag/commit
  src = fetchFromGitHub {
    owner = "x71c9";
    repo = "dogma";
    rev = "v${version}";
    hash = "sha256-0IhLBGtqjOvXXrcJhYoAEZ5YbuNnU2u7WcTJ0ET92VE=";
  };

  # Vendor Cargo dependencies from the committed lockfile.
  # Avoids the crates.io download API (HTTP 403) used by fetch-cargo-vendor;
  # registry crates are fetched from static.crates.io instead.
  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = lib.optional completion.enable installShellFiles;

  # Enable when you have tests (recommended)
  doCheck = false;

  postInstall = lib.optionalString completion.enable (
    let
      shellCompletionDir = {
        bash = "share/bash-completion/completions";
        zsh = "share/zsh/site-functions"; 
        fish = "share/fish/vendor_completions.d";
      };
      shellCompletionFile = {
        bash = "dogma";
        zsh = "_dogma";
        fish = "dogma.fish";
      };
      
      generateCompletions = shell: ''
        mkdir -p $out/${shellCompletionDir.${shell}}
        $out/bin/dogma completions ${shell} > $out/${shellCompletionDir.${shell}}/${shellCompletionFile.${shell}}
      '';
    in
      lib.concatMapStringsSep "\n" generateCompletions completion.shells
  );

  # If the binary name differs from pname, set mainProgram accordingly
  mainProgram = "dogma";

  meta = with lib; {
    description = "CLI to bridge secrets from any vault backend and infra outputs into sops-encrypted files, deployed to your machines — driven by a single dogma.yml";
    homepage = "https://github.com/x71c9/dogma";
    license = licenses.mit;
    maintainers = []; # keep empty unless you're in nixpkgs' maintainers set
    platforms = platforms.linux ++ platforms.darwin;
  };
}

