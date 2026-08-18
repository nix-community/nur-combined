{
  amethyst-mod-manager,
  fetchFromGitHub,
}:

amethyst-mod-manager.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "amethyst-mod-manager-beta";
    version = "2.2.1-beta.2";

    src = fetchFromGitHub {
      inherit (previousAttrs.src) owner repo;
      tag = "v${finalAttrs.version}";
      hash = "sha256-v1IZpMDKiQ9XIFi1ZEB1SD3RAO6b59vum16JeR9vY9I=";
    };
  }
)
