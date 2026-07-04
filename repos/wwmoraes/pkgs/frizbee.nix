{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule (finalAttrs: {
  pname = "frizbee";
  version = "0.1.10";

  src = fetchFromGitHub {
    owner = "stacklok";
    repo = "frizbee";
    tag = "v${finalAttrs.version}";
    hash = "sha256-omuvT9n3K6t74B+rYu24GTgR+jx3qsOLSOVcz4wOsuI=";
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > COMMIT
      git log --date=iso8601-strict -1 --pretty=%ct > COMMIT_DATE
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  vendorHash = "sha256-XJJ9375jJ0lN0VRO2c9QoG+1jkBmzKZG+T1DIHaLaq0=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X main.TreeState=clean"
    "-X github.com/stacklok/frizbee/pkg/constants.CLIVersion=${finalAttrs.version}"
  ];

  preBuild = ''
    ldflags+=" -X main.Commit=$(cat $src/COMMIT)"
    ldflags+=" -X main.CommitDate=$(cat $src/COMMIT_DATE)"
  '';

  doCheck = false;

  meta = with lib; {
    description = "Throw a tag at it and it comes back with a checksum.";
    homepage = "https://github.com/stacklok/frizbee";
    license = licenses.asl20;
    mainProgram = "frizbee";
    maintainers = with maintainers; [ wwmoraes ];
  };
})
