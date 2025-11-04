{
  lib,
  buildGoModule,
  fetchFromGitHub,
  callPackage,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "bobgen";
  version = "0.41.1";

  src = fetchFromGitHub {
    owner = "stephenafamo";
    repo = "bob";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HaWeiC1sxJz2wWYsvopD8ufFZlpMiA1GkfzrnDvP1XM=";
  };

  vendorHash = "sha256-Jqlah37+tfNqsgeL/MnbVUmSfU2JWMJDb9AQrEqXnXU=";

  subPackages = [
    "gen/bobgen-sql"
    "gen/bobgen-psql"
    "gen/bobgen-mysql"
    "gen/bobgen-sqlite"
  ];

  passthru = {
    unstable = callPackage ./unstable.nix {
      bobgen = finalAttrs.finalPackage;
    };
    updateScript = lib.concatStringsSep " " (nix-update-script {
      extraArgs = [
        "--commit"
        "packages.${finalAttrs.pname}"
      ];
    });
  };

  meta = {
    description = "SQL query builder and ORM/Factory generator for Go";
    homepage = "https://github.com/stephenafamo/bob";
    changelog = "https://github.com/stephenafamo/bob/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
