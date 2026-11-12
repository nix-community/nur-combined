{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
  openssl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "myx";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "HaseebKhalid1507";
    repo = "Myx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dOcQgiq+XHXEoMvQjjwKhJ4ciMDKYCAEWVxrLxlk8yA=";
  };

  cargoHash = "sha256-rA6s8yE2CTfR9in+NUnvDm/1+Zhs4u5eTe2QfSI/xK8=";

  nativeBuildInputs = [pkg-config];

  buildInputs = [
    alsa-lib
    openssl
  ];

  meta = {
    description = "Lean, beautiful terminal Spotify player";
    homepage = "https://github.com/HaseebKhalid1507/Myx";
    changelog = "https://github.com/HaseebKhalid1507/Myx/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "myx";
  };
})
