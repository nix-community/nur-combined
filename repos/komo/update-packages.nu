const nix_file = path self ./default.nix

let old_commit = git rev-parse HEAD
let packages = (
  nix eval
    --impure
    --json
    --expr r#'
      with import <nixpkgs> {};
      map
        (x: x.name)
        (builtins.filter
          (x: lib.isDerivation x.value)
          (lib.attrsToList (import ./. {})))
    '#
  | from json 
)

$packages | par-each {|name|
  let current_commit = git rev-parse HEAD
  
  try {
    nix-update --commit --flake $name
  } catch {
    return
  }

  try {
    nix build -L --no-link --impure --expr $"\(import ./. {}).\"($name)\""
  } catch {
    if (git rev-parse HEAD) == $current_commit { return }
    git reset --hard HEAD~1
  }
}

if (git rev-parse HEAD) == $old_commit { exit }

git reset --soft $old_commit
git commit -m $"update package\(s)\n(git log --format=%s)"
