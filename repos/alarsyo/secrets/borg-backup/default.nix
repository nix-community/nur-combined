{ lib }:
{
  boreal-repo = lib.fileContents ./boreal-repo.secret;
  poseidon-repo = lib.fileContents ./poseidon-repo.secret;
}
