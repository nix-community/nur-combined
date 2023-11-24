{ lib
, buildGoModule
, fetchFromGitHub
, buster-client
, go-bindata
}:

buildGoModule rec {
  pname = "buster-client-setup";
  inherit (buster-client) version src;

  # note: this will change on update of buster-client
  vendorHash = "sha256-+0pIbroARyRR9zeHOl96PZ7G5UzGgUIc0jvGCDcLkVQ=";

  modRoot = "cmd/setup";

  ldflags = [
    "-s"
    "-w"
    "-X=main.name=${pname}"
    "-X=main.version=${version}"
    "-X=main.buildVersion=${version}"
    "-X=main.commit=${src.rev}"
    "-X=main.date=1970-01-01T00:00:00Z"
  ];

  # based on buster-client/Makefile
  # the buster-client binary is embedded into the buster-client-setup binary
  # note: we need to set prefix so the asset name is "buster-client"
  preBuild = ''
    ${go-bindata}/bin/go-bindata -mode 0755 -o clientbin.go \
      -prefix $(dirname ${buster-client}/${buster-client.binPath}) \
      ${buster-client}/${buster-client.binPath}
  '';

  postInstall = ''
    mv $out/bin/setup $out/bin/buster-client-setup
  '';

  meta = with lib; {
    description = "User input simulation for Buster";
    homepage = "https://github.com/dessant/buster-client";
    changelog = "https://github.com/dessant/buster-client/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "buster-client";
    platforms = platforms.all;
  };
}
