final: prev:
{
  nix-serve-ng = prev.nix-serve-ng.overrideAttrs (oa: {
    src = final.fetchFromGitHub {
      owner = "aristanetworks";
      repo = "nix-serve-ng";
      rev = "dabf46d65d8e3be80fa2eacd229eb3e621add4bd";
      hash = "sha256-SoJJ3rMtDMfUzBSzuGMY538HDIj/s8bPf8CjIkpqY2w=";
    };
  });
}
