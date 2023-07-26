{ buildGoModule, fetchFromGitHub, lib, nix-update-script }:

buildGoModule rec {
  pname = "lean-cli";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "leancloud";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-fIkNeZdhyTH2BmvMOXZG2iu31KQaySQY/+6lAlRFjfk=";
  };

  vendorHash = "sha256-mSEYvhBvcfCai3AvZkpQEcYJ5KG8/AJO9EZ7yZ7hzLI=";

  passthru.updateScript = nix-update-script { };

  # source code contains e2e tests, which requires a LeanCloud account
  doCheck = false;

  meta = with lib; {
    description = "LeanEngine Command Line Tool";
    homepage = "https://github.com/leancloud/lean-cli/tree/master";
    license = licenses.asl20;
    mainProgram = "lean";
    maintainers = [ {
      name = "NotEvenANeko";
      email = "neko@qwq.icu";
      github = "NotEvenANeko";
      githubId = 49067249;

      keys = [{
        fingerprint = "C7C3 8D62 BCC4 0F16 9EB2 B89B 3DC2 A7C6 1244 603E";
      }];
    } ];
  };
}
