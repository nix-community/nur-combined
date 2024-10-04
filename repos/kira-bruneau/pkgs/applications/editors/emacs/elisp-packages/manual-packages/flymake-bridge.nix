{
  lib,
  melpaBuild,
  fetchFromGitHub,
  lsp-bridge,
  nix-update-script,
}:

melpaBuild {
  pname = "flymake-bridge";
  version = "0-unstable-2023-10-08";

  src = fetchFromGitHub {
    owner = "liuyinz";
    repo = "flymake-bridge";
    rev = "30f7ee8c5234b32c6d5acac850bb97c13ee90128";
    hash = "sha256-qpGBt0LUEQuI0wbTP69uUC7exa9LqwGh7uc1gNqDFfw=";
  };

  packageRequires = [ lsp-bridge ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "lsp-bridge Flymake backend for server diagnostics";
    homepage = "https://github.com/liuyinz/flymake-bridge";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ kira-bruneau ];
  };
}
