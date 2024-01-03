{
  fetchFromGitHub,
  nixpkgs-review,
  python3Packages,
}:
nixpkgs-review.overrideAttrs (finalAttrs: prevAttrs: {
  version = prevAttrs.version + "-fork-2024-01-03";
  name = "${prevAttrs.pname}-${finalAttrs.version}";
  src = fetchFromGitHub {
    owner = "natsukium";
    repo = "nixpkgs-review";
    rev = "236d75ca105090170934f6f33abbd04d0fdb30fd";
    hash = "sha256-+DWTeOnglwqLZ9Hke1Y2oCW1pYXPIrutnOXnBLply08=";
  };
  propagatedBuildInputs =
    prevAttrs.propagatedBuildInputs
    ++ (with python3Packages; [
      backoff
      humanize
    ]);
})
