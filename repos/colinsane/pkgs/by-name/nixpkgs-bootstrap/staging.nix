{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "25ff165fbddc780f025f7dabcbae1e31ed775a06";
  sha256 = "sha256-m+vKIF8HVBEGS9lbngA0stofrQBMuAmC4TrIEQQw30M=";
  version = "unstable-2025-12-08";
  branch = "staging";
}
