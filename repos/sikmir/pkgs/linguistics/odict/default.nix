{
  lib,
  fetchFromGitHub,
  buildGoModule,
  testers,
  odict,
}:

buildGoModule rec {
  pname = "odict";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "TheOpenDictionary";
    repo = "odict";
    tag = version;
    hash = "sha256-2520kNT3aTylE0ZVGuX92z1NehdCKKvGKd8OgdJ1q3M=";
  };

  vendorHash = "sha256-8vDlrbdmGfpCLZIU3rxuk004T9om/CGTc8vJElvlP3s=";

  passthru.tests.version = testers.testVersion { package = odict; };

  meta = {
    description = "A blazingly-fast portable dictionary file format";
    homepage = "https://odict.org/";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
