{ fetchFromGitHub }:

final: prev: {
  clash-verge-rev = prev.clash-verge-rev.overrideAttrs (old: {
    src = fetchFromGitHub {
      owner = "clash-verge-rev";
      repo = "clash-verge-rev";
      rev = "master";
      sha256 = "";
    };
    pnpm-hash = "";
    vendor-hash = "";
  });
}
