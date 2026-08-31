let eval_result = (
  nix-env -f ./default.nix -qa \* --meta --json \
    --allowed-uris https://static.rust-lang.org \
    --option restrict-eval true \
    --option allow-import-from-derivation true \
    --drv-path --show-trace \
    -I nixpkgs=(nix-instantiate --find-file nixpkgs) \
    -I $env.PWD
  | from json
)

$env.paths = []

def eval [parent: string, key: string, v: any] {
  match ($v | describe) {
    $it if $it starts-with "list" => {
      $v | enumerate 
         | each {|e|
           eval $"($parent)/($key)" ($e.index + 1 | into string) $e.item
          }
    },
    $it if $it starts-with "record" => {
      $v | items {|subkey, subv|
        eval $"($parent)/($key)" $subkey $subv
      }
    },
    _ => {
      $env.paths ++= [$"($parent)/($key): ($v | into string)"]
    },
  }
}

eval "eval" "/" $eval_result
$env.paths | str join "\n" | as-tree
