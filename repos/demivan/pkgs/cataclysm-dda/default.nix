{
  cataclysm-dda-git,
  fetchFromGitHub,
}:
cataclysm-dda-git.overrideAttrs (old: {
  version = "2024.06.02";

  src = fetchFromGitHub {
    owner = "CleverRaven";
    repo = "Cataclysm-DDA";
    rev = "f608d5b853e0d9d8492e2bc64166d60cc5d21007";
    sha256 = "sha256-h1hfIEpz8tETTvNAm2fD3RWaVoem55yce34NW3ATuqg=";
  };

  patches = [
  ];
})
