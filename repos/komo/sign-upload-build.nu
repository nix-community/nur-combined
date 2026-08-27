const result_file = path self ./result.json
const signing_pem_file = path self ./signing-key.pem

if ($signing_pem_file | path exists) == false {
  panic "cannot find ./signing-key.pem, have you created a store key?"
}

if !($result_file | path exists) == false {
  panic "cannot find ./result.json, did you forgot to nix-fast-build?"
}

let results = open $result_file | get results
let built_derivations = $results | where type == "BUILD" and success == true
let path_outputs = $built_derivations | get outputs | each { values } | flatten

if ($path_outputs | length) == 0 {
  exit
}

def main [--binary-cache: string] {
  nix store sign --key-file $signing_pem_file ...$path_outputs
  nix copy --to $binary_cache ...$path_outputs
}
