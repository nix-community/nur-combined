{ writeShellScriptBin, lib }:
writeShellScriptBin "pre-commit" ''
  echo "Stashing unstaged changes..."
  git commit --allow-empty --no-verify --message 'Save index'
  stash_output=$(git stash push --include-untracked --message 'Unstaged changes')
  echo $stash_output
  git reset --soft HEAD^

  echo "Formatting..."
  nix fmt

  git add --all

  if [ -n "$stash_output" ] && [ "$stash_output" != "No local changes to save" ]; then
      echo "Restoring unstaged changes..."
      git stash pop
  else
      echo "No unstaged changes to restore."
  fi
''
// {
  meta = {
    description = "Pre-commit hook that formats staged changes with nix fmt";
    homepage = "https://github.com/ToyVo/nixcfg";
    license = lib.licenses.mit;
    mainProgram = "pre-commit";
  };
}
