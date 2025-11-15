{ lib, rustPlatform, fetchFromGitHub, installShellFiles
, completion ? { enable = true; shells = [ "bash" ]; }
}:

rustPlatform.buildRustPackage rec {
  pname = "tempesta";
  version = "0.1.9"; # without "v"

  # Pin the source to an immutable tag/commit
  src = fetchFromGitHub {
    owner = "x71c9";
    repo = "tempesta";
    rev = "v${version}";
    hash = "sha256-N0ge3j1BuiGR0zxaXv+5Ya/h8sR+kZEoKgzmqf+pZzk=";
  };

  # Cargo dependency vendor hash (computed by Nix)
  cargoHash = "sha256-TQHmxI4kzGVkkIzBLiDZarN+ErWYH2oSJFLYVuVqLLs=";

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
        bash = "tempesta";
        zsh = "_tempesta";
        fish = "tempesta.fish";
      };
      
      generateCompletions = shell: ''
        mkdir -p $out/${shellCompletionDir.${shell}}
        $out/bin/tempesta completion ${shell} > $out/${shellCompletionDir.${shell}}/${shellCompletionFile.${shell}}
      '';
    in
      lib.concatMapStringsSep "\n" generateCompletions completion.shells
  );

  # If the binary name differs from pname, set mainProgram accordingly
  mainProgram = "tempesta";

  meta = with lib; {
    description = "The fastest and lightest bookmark manager CLI written in Rust";
    homepage = "https://github.com/x71c9/tempesta";
    license = licenses.mit;
    maintainers = []; # keep empty unless you're in nixpkgs' maintainers set
    platforms = platforms.linux ++ platforms.darwin;
  };
}

