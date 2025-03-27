{
  fetchFromGitea,
  htmlq,
  lib,
  neovimUtils,
  tree,
  tree-sitter,
  tree-sitter-nix-shell,
}:

tree-sitter.buildGrammar {
  version = "0.2.0";
  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "tree-sitter-nix-shell";
    rev = "41849dc40d776841a3104d15c8b8ac69425f17f7";
    hash = "sha256-6+I3EiKj82yzyteV1jkhI2aHaBPw5E7cLUztnYhieWk=";
  };

  language = "nix-shell";
  location = "tree-sitter-nix-shell";
  generate = true;

  nativeCheckInputs = [ htmlq ];
  checkPhase = ''
    runHook preCheck
    (cd ..; make test)
    runHook postCheck
  '';
  doCheck = true;

  nativeInstallCheckInputs = [ tree ];
  installCheckPhase = ''
    runHook preInstallCheck

    # i'm too dumb to know which installed files are necessary for e.g. neovim,
    # but the original package (pre 2025-03-15) had:
    # - $out/parser (elf file; also found in e.g. vimPlugins.nvim-treesitter.grammarPlugins.latex.origGrammar)
    # - $out/queries/{highlights.scm,injections.scm}
    #
    # N.B. that said original parser never actually worked with neovim (only with helix?)
    (test -x $out/parser && test -f $out/queries/highlights.scm && test -f $out/queries/injections.scm) || \
      (tree $out; echo "expected output to contain /parser and /queries/"; false)

    runHook postInstallCheck
  '';
  doInstallCheck = true;

  passthru = {
    generated = tree-sitter-nix-shell.overrideAttrs (orig: {
      # provide a package which has the output of `tree-sitter generate`, but not the binary compiled parser
      dontBuild = true;
      installPhase = "cp -r . $out";
      doCheck = false;
      doInstallCheck = false;
    });
    # see comment in <repo:nixos/nixpkgs:pkgs/applications/editors/neovim/utils.nix>
    nvimPlugin = neovimUtils.grammarToPlugin tree-sitter-nix-shell;
  };

  meta = with lib; {
    description = "parse `#!/usr/bin/env nix-shell` scripts with tree-sitter";
    homepage = "https://git.uninsane.org/colin/tree-sitter-nix-shell";
    maintainers = with maintainers; [ colinsane ];
  };
}
