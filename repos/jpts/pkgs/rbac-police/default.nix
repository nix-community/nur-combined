{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  fetchpatch,
}:
buildGoModule rec {
  pname = "rbac-police";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "PaloAltoNetworks";
    repo = "rbac-police";
    rev = "v${version}";
    sha256 = "sha256-TbjN+xH3DIfzwxA7p9NCvWkvz4bEUPilsq685DgiV1k=";
  };
  vendorSha256 = "sha256-oTvXlJpcplT6W5XMMuC9oNkYaTku1MHGRVE9eLz4H3M=";
  patches = [
    (fetchpatch {
      name = "fix-utils.patch";
      url = "https://github.com/PaloAltoNetworks/rbac-police/commit/ab2db327a9377463f2ddee3e7be522fdbaf44b8c.patch";
      sha256 = "sha256-SlDIcvoVx1vsO/Cr+3906Iu9uezgSPrR/5niyX6ZVnI=";
    })
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  ## copy over std policy library
  postInstall = ''
    mkdir -p $out/lib/rbac-police/
    cp -r ./lib/* $out/lib/rbac-police/
  '';

  meta = with lib; {
    homepage = "https://github.com/PaloAltoNetworks/rbac-police";
    changelog = "https://github.com/PaloAltoNetworks/rbac-police/releases/tag/v${version}";
    description = "Evaluate the RBAC permissions of Kubernetes identities through policies written in Rego";
    longDescription = ''
      Retrieve the RBAC permissions of Kubernetes identities - service accounts, pods, nodes, users and groups - and evaluate them using policies written in Rego.
      The policy library includes over 20 policies that detect identities possessing risky permissions, each alerting on a different attack path.
    '';
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
  };
}
