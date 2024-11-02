{
  cataclysm-dda-git,
  fetchFromGitHub,
}:
cataclysm-dda-git.overrideAttrs (old: {
  version = "unstable-2024-11-01";

  src = fetchFromGitHub {
    owner = "CleverRaven";
    repo = "Cataclysm-DDA";
    rev = "46ce09bc32c2898b55085a4ae0fadb57e8f0d354"; # tags/cdda-experimental-*
    sha256 = "0badw939avvi2z8lx0qb9xsg5k3rr4gdl8fi914xild09n50qdx8";
  };

  patches = [
  ];
})
