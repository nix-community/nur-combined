{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "mcp-language-server";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "isaacphi";
    repo = "mcp-language-server";
    rev = "v${finalAttrs.version}";
    hash = "sha256-T0wuPSShJqVW+CcQHQuZnh3JOwqUxAKv1OCHwZMr7KM=";
  };

  vendorHash = "sha256-3NEG9o5AF2ZEFWkA9Gub8vn6DNptN6DwVcn/oR8ujW0=";

  subPackages = ["."];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Language server integration for MCP enabled clients";
    longDescription = ''
      MCP language server provides semantic tools like get definition,
      references, rename, and diagnostics for MCP enabled clients.
      Supports Go, Rust, Python, TypeScript, and C/C++.
    '';
    homepage = "https://github.com/isaacphi/mcp-language-server";
    license = lib.licenses.bsd3;
    maintainers = [];
    mainProgram = "mcp-language-server";
  };
})
