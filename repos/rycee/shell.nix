let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
  git-hooks = import sources.git-hooks;

  pre-commit-check = git-hooks.run {
    src = pkgs.nix-gitignore.gitignoreSource [ ] ./.;
    hooks = {
      nixfmt = {
        enable = true;
        package = pkgs.nixfmt-classic;
      };

      format-addons-json = {
        enable = true;
        name = "Format addons.json";
        entry = toString (pkgs.writeShellScript "format-addons-json" ''
          jq 'sort_by(.slug)' < pkgs/firefox-addons/addons.json \
            | sponge pkgs/firefox-addons/addons.json
        '');
        files = "pkgs/firefox-addons/addons\\.json";
      };
    };
  };
in pkgs.mkShell {
  nativeBuildInputs = with pkgs; [ npins ] ++ pre-commit-check.enabledPackages;
  shellHook = ''
    ${pre-commit-check.shellHook}
  '';
}
