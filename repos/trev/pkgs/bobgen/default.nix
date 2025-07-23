{
  lib,
  buildGoModule,
  fetchFromGitHub,
  callPackage,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "bobgen";
  version = "0.38.0";

  src = fetchFromGitHub {
    owner = "stephenafamo";
    repo = "bob";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pIw+fFnkkYJMYoftxSBwBZzJkhYBLjknOENDibVjJk4=";
  };

  vendorHash = "sha256-iVYzRKIUrjR/pzlpUMtgaFBn5idd/TBsSZxh/SQGT0M=";

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
        "${finalAttrs.pname}"
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
