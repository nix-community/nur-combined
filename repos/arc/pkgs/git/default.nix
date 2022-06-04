{
  hook-chain = import ./hook-chain.nix;
  git-fixup = import ./git-fixup.nix;
  git-continue = import ./git-continue.nix;
  git-annex-remote-b2 = import ./git-annex-remote-b2;
  git-remote-s3 = import ./git-remote-s3.nix;
}
