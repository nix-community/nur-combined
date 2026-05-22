{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "bobgen";
  version = "0.44.0";

  src = fetchFromGitHub {
    owner = "stephenafamo";
    repo = "bob";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FwS/8nSo19sJ3OPX2z52A4Pwglow8ZIKMjWLo+faah8=";
  };

  vendorHash = "sha256-WzSUUgfWGz5XXq3iQrtpF91yOEr0QypTWq1rOJMntGQ=";

  subPackages = [
    "gen/bobgen-sql"
    "gen/bobgen-psql"
    "gen/bobgen-mysql"
    "gen/bobgen-sqlite"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    description = "SQL query builder and ORM/Factory generator for Go";
    mainProgram = "bobgen-sql";
    homepage = "https://github.com/stephenafamo/bob";
    changelog = "https://github.com/stephenafamo/bob/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
