{ lib }:
let
  inherit (lib)
    fileContents
  ;
in
{
  boreal-repo = fileContents ./boreal-repo.secret;
  poseidon-repo = fileContents ./poseidon-repo.secret;
}
