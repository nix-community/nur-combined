{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "0fba85408e8856e3dc165dde47f97435c4e1b339";
  sha256 = "sha256-JA7aZxXO0UO5qfL9h1mvKAi+WGD6nV/PPTdMP9UnL+w=";
  version = "0-unstable-2025-04-02";
  branch = "staging";
}
