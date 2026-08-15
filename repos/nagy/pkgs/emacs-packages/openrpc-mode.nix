{
  lib,
  melpaBuild,
  fetchFromGitHub,
  jsonrpc,
}:

melpaBuild {
  pname = "openrpc-mode";
  version = "0-unstable-2026-08-15";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "emacs-openrpc-mode";
    rev = "7861b25eb808314eef057aeaa28f1f9577bb50f6";
    hash = "sha256-34CXTFfj+gfzYvyL/QiRrI8+/kNL3dubB/QXQFkiZm0=";
  };

  packageRequires = [
    jsonrpc
  ];

  turnCompilationWarningToError = true;

  meta = {
    homepage = "https://github.com/nagy/emacs-openrpc-mode";
    description = "Introspect JSON-RPC commands and servers via OpenRPC";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
