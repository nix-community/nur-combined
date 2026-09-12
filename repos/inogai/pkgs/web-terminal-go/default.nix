# web-terminal-go: 4weaver/web-terminal, the Go-server fork of
# code-yeongyu/web-terminal (mobile-first self-hosted web terminal on
# coder/ghostty-web). The fork replaces the original Bun/TypeScript server with
# a static Go binary — no JS runtime on the server, so buildGoModule is the
# whole story (the old bun packaging idea does not apply).
#
# The frontend (`web/`, incl. ghostty-vt.wasm) is served from disk, not
# embedded; the binary defaults WT_STATIC_DIR to the relative path "web", so
# the unwrapped binary 404s unless cwd happens to be the source root. Ship a
# wrapper that points at the installed assets.
#
# Not implemented upstream yet: auth (no WT_PASSWORD/argon2). Bind loopback and
# put an authenticating proxy in front; do not expose it directly.
{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeBinaryWrapper,
}:
buildGoModule (finalAttrs: {
  pname = "web-terminal-go";
  version = "0.1.0-unstable-2026-09-12";

  src = fetchFromGitHub {
    owner = "4weaver";
    repo = "web-terminal";
    # main: Go server (2 commits over upstream 1351723)
    rev = "ffc641e115e48c03953d57f3f46608f4fc0d95e0";
    hash = "sha256-DEIaDxziDTxvzhBdQ9y4b8oPf1zMiOM0wfKy97frJCE=";
  };

  vendorHash = "sha256-LjM5B6PRL6rNAJ43+RBzKmRsPTNgE+TMeLkUfOVidqs=";

  # Build only the root package (cmd/wstest must not be installed).
  # web/ stays in src; installPhase copies it next to the binary below.
  subPackages = [ "." ];

  nativeBuildInputs = [makeBinaryWrapper];

  postInstall = ''
    runHook prePostInstall

    mkdir -p $out/share/web-terminal-go
    cp -r web $out/share/web-terminal-go/web

    # pname matches the Go module path, so the binary is already named
    # web-terminal-go. Wrap it so WT_STATIC_DIR points at the assets
    # regardless of the cwd it is launched from.
    mv $out/bin/web-terminal-go $out/bin/.web-terminal-go-wrapped
    makeBinaryWrapper $out/bin/.web-terminal-go-wrapped $out/bin/web-terminal-go \
      --prefix WT_STATIC_DIR : $out/share/web-terminal-go/web
    runHook postPostInstall
  '';

  # No doInstallCheck: the binary takes no CLI arguments at all (config is
  # WT_* env only, see internal/web/server.go), so there is no --version to call.

  meta = {
    description = "Mobile-first self-hosted web terminal (Go-server fork of code-yeongyu/web-terminal)";
    homepage = "https://github.com/4weaver/web-terminal";
    changelog = "https://github.com/4weaver/web-terminal/commits/main";
    license = lib.licenses.mit;
    maintainers = [lib.maintainers.inogai];
    mainProgram = "web-terminal-go";
    platforms = lib.platforms.all;
  };
})
