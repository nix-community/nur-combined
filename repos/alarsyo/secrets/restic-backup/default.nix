{ lib }:
{
  poseidon-repo = lib.fileContents ./poseidon-repo.secret;
}
