{ helix
, rsync
, substituteAll
, tree-sitter-nix-shell
}:

let
  languages = substituteAll {
    src = ./languages.toml;
    tree_sitter_nix_shell = tree-sitter-nix-shell.generated;
  };
in
helix.overrideAttrs (upstream: {
  nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
    rsync
  ];
  configurePhase = (upstream.configurePhase or "") + ''
    cat ${languages} >> languages.toml
    substituteAllInPlace languages.toml

    rsync -arv ${tree-sitter-nix-shell.generated}/ runtime/grammars/sources/nix-shell/
    rsync -arv ${tree-sitter-nix-shell}/queries/ runtime/queries/nix-shell/

    # helix tries to delete the sources during installPhase
    chmod -R +w runtime/grammars/sources/nix-shell
  '';
})
