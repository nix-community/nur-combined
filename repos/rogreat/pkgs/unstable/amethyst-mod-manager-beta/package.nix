{
  amethyst-mod-manager,
  fetchFromGitHub,
}:

amethyst-mod-manager.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "amethyst-mod-manager-beta";
    version = "2.2.1-beta.5";

    src = fetchFromGitHub {
      inherit (previousAttrs.src) owner repo;
      tag = "v${finalAttrs.version}";
      hash = "sha256-naELUWgwGOdvS4zCJMqKNcmy4aVFYgW0s1vCxrElvM4=";
    };
  }
)
