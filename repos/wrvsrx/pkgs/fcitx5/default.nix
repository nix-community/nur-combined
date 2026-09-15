{
  fcitx5,
  fetchFromGitHub,
}:
fcitx5.overrideAttrs (
  finalAttrs: oldAttrs: {
    version = "5.1.12+unstable-2026-09-12";
    src = fetchFromGitHub {
      inherit (oldAttrs.src) owner repo;
      rev = "d6552a5b52b4ff75cae3fb6dc949ef379171b2b9";
      hash = "sha256-wN3FSFp3qqxtoPXVvc342caPCbYBfgD61ilEmbYgQCk=";
    };
  }
)
