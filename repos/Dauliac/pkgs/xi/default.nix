# xi - a nix cli helper (https://github.com/Dauliac/xi).
#
# Upstream builds this with crane (see flake.nix / nix/packages.nix in the xi
# repo), which also generates shell completions and a man page via its xtask
# binary and wraps the result with nix-output-monitor / nix-fast-build /
# nix-auth on PATH. Here we rebuild the `xi` binary itself with plain
# nixpkgs `rustPlatform` so NUR evaluation needs nothing but nixpkgs: no
# crane, no second nixpkgs, no unhashed fetch. Shell completions/man pages and
# the nix-auth PATH wrapper (not in nixpkgs) are dropped as a result; nom and
# nix-fast-build are both in nixpkgs so those stay wrapped in.
# Keep in sync with upstream's Cargo.toml workspace.package.version.

{ lib
, rustPlatform
, fetchFromGitHub
, makeWrapper
, nix-output-monitor
, nix-fast-build
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xi";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "Dauliac";
    repo = "xi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IBXecl8a3sHx4hi5y4yE1W0FcD8ZH9rQ+SSn1ulhZW0=";
  };

  cargoHash = "sha256-HVU+fGdtqH5pSy3d+sHHh1c2wOJZCj43p3rmJp8liUw=";

  # Workspace root has no [package]; build/install the `xi` member only
  # (its path-dependencies on xi-core/xi-auth/etc. are pulled in for free).
  buildAndTestSubdir = "crates/xi";

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/xi \
      --prefix PATH : ${lib.makeBinPath [ nix-output-monitor nix-fast-build ]}
  '';

  meta = {
    description = "Yet another nix cli helper";
    homepage = "https://github.com/Dauliac/xi";
    license = lib.licenses.eupl12;
    mainProgram = "xi";
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
