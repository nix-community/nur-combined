{ buildGoModule, fetchFromGitHub, lib, nix-update-script, git }:

buildGoModule rec {
  pname = "atlas";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "ariga";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-BxTgIfqg5AFYvSqf4++wB2SBKEPW1TBC3mb9YpHM0Q4=";
  };

  modRoot = "cmd/atlas";

  proxyVendor = true;
  vendorHash = "sha256-hzXqT5pQ0Q/IELSoMwrhmrY1pw0jOUukShnNowsQt6o=";

  ldflags = [
    "-s"
    "-w"
    "-X ariga.io/atlas/cmd/atlas/internal/cmdapi.flavor=community"
    "-X ariga.io/atlas/cmd/atlas/internal/cmdapi.version=v${version}"
  ];

  passthru.updateScript = nix-update-script { };

  # L1-2: this test case presume that sed in darwin is BSD sed, but coreutils includes GNU sed
  # remove this if statement
  #
  # L3: the string `Atlas CLI - development` it hardcoded in 0.12.0,
  # but it should be `Atlas CLI v0.12.0`
  # replace it with what it shoule be
  #
  # https://github.com/NixOS/nixpkgs/issues/197774
  postPatch = ''
    sed -zEi 's/if runtime\.GOOS == "darwin" \{[^}]+\}//' cmd/atlas/internal/cmdapi/migrate_test.go
    sed -Ei 's/\"runtime\"//' cmd/atlas/internal/cmdapi/migrate_test.go
    sed -Ei 's/Atlas CLI - development/Atlas CLI v${version}/' cmd/atlas/internal/cmdapi/migrate_test.go
  '';

  nativeCheckInputs = [ git ];

  meta = with lib; {
    description = "Atlas is a tool for managing and migrating database schemas using modern DevOps principles";
    homepage = "https://atlasgo.io/";
    license = licenses.asl20;
    mainProgram = "atlas";
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
