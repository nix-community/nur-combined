{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
# v0.0.8's go.mod requires go >= 1.27.3, which nixpkgs' default `go`
# (1.27.3) satisfies. v1.0.0 raises that to 1.27.4 and its own tests assert
# the toolchain (TestGoToolchainAtLeast1274), which nixpkgs' go_1_27 (1.27.3)
# cannot satisfy — revisit once it ships 1.27.4.
buildGoModule rec {
  pname = "truenas-mcp";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "truenas";
    repo = "truenas-mcp";
    rev = "v${version}";
    hash = "sha256-VclKB02SOQx8HoYF3eyfjnVH5JfyubA+oVzqAmRtbAM=";
  };
  vendorHash = "sha256-L7+NJP3SAL0fNvxH12E8Ak8tf6oKe5zUVHdXXteUIh8=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  meta = with lib; {
    description = "Monitor and Manage your TrueNAS via LLM using an MCP plugin.";
    homepage = "https://github.com/truenas/truenas-mcp";
    license = licenses.gpl3Only;
    mainProgram = pname;
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
