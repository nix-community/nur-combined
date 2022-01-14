{ lib }:
let
  inherit (lib)
    fileContents
  ;
in
{
  poseidon-repo = fileContents ./poseidon-repo.secret;
}
