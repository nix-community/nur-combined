{ pkgs }: {
  pkgs = let
    model2vec = pkgs.callPackage ./pkgs/minishLab/model2vec.nix { };
    vicinity = pkgs.callPackage ./pkgs/minishLab/vicinity.nix { };
    bm25s = pkgs.callPackage ./pkgs/bm25s.nix { };
    tree-sitter-language-pack = pkgs.callPackage ./pkgs/tree-sitter-language-pack.nix { };
    pathspec = pkgs.callPackage ./pkgs/pathspec.nix { };
  in {
    riscVivid = pkgs.callPackage ./pkgs/riscVivid { };
    systemd-sops-creds = pkgs.callPackage ./pkgs/systemd-sops-creds.nix { };
    simple-llm-router = pkgs.callPackage ./pkgs/simple-llm-router.nix { };
    filebrowser-quantum = pkgs.callPackage ./pkgs/filebrowser-quantum.nix { };
    beszel-provisioner = pkgs.callPackage ./pkgs/beszel-provisioner.nix { };
    carddav-immich-bday-sync = pkgs.callPackage ./pkgs/carddav-immich-bday-sync { };
    upsnap = pkgs.callPackage ./pkgs/upsnap.nix { };
    
    semble = pkgs.callPackage ./pkgs/minishLab/semble { inherit model2vec vicinity bm25s tree-sitter-language-pack pathspec; };
    inherit model2vec vicinity bm25s tree-sitter-language-pack pathspec;
  };
}
