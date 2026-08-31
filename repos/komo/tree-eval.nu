let eval_result = (
  nix-env -f ./default.nix -qa "*" --meta --json
    --allowed-uris https://static.rust-lang.org
    --option restrict-eval true
    --option allow-import-from-derivation true
    --drv-path --show-trace
    -I nixpkgs=flake:nixpkgs
    -I $env.PWD
  | from json
)

def eval [paths: list, parent: string, key: string, v: any] {
  match ($v | describe) {
    $it if $it starts-with "list" => {
      $v | enumerate 
         | each {|e|
             eval $paths $"($parent)/($key)" ($e.index + 1 | into string) $e.item
           }
         | flatten
    },
    $it if $it starts-with "record" => {
      $v | items {|subkey, subv|
             eval $paths $"($parent)/($key)" $subkey $subv
           }
         | flatten
    },
    _ => {
      [$"($parent)/($key): ($v | default "<nothing>"| into string | str replace -a "/" "╱")"]
    },
  }
}

eval [] "." "/" $eval_result | str join "\n" | as-tree
