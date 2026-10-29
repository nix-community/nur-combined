# vault-sessions-manager - manage multiple HashiCorp Vault contexts/sessions.
#
# Upstream builds this with crane + a rust-overlay-pinned 1.90 toolchain
# (see modules/crane-build.nix in the vsm repo). Here we rebuild it against
# plain nixpkgs `rustPlatform` so that NUR evaluation needs nothing but
# nixpkgs: no crane, no rust-overlay, no second nixpkgs, no unhashed fetch.
# Keep the two in sync when bumping `version`.

{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, dbus
, makeWrapper
, xdg-utils
, vault
  # `vault` is BUSL-1.1, which Nixpkgs treats as unfree. Forcing its outPath
  # (as `lib.makeBinPath` does) throws under the default `allowUnfree = false`,
  # and NUR's evaluator runs with exactly that - so an unconditional wrapper
  # would break evaluation of this whole repository, not merely this attribute.
  # The wrapper is therefore opt-in:
  #     pkgs.nur.repos.Dauliac.vsm.override { withVaultWrapper = true; }
  # with `allowUnfree = true` in your nixpkgs config. With the wrapper off,
  # `vsm` resolves `vault` from the ambient PATH at runtime instead.
, withVaultWrapper ? false
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vsm";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Dauliac";
    repo = "vault-sessions-manager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VpZaFaLayzSaomNi+Z3FWnQP/pBjFn5zna9NxrmvuA0=";
  };

  cargoHash = "sha256-7T5kSa54dFNWkYlXSap/mUzuxZWn41PIvE2/heWOWlc=";

  nativeBuildInputs = [ pkg-config ] ++ lib.optional withVaultWrapper makeWrapper;

  # The `keyring` crate's sync-secret-service backend links against dbus.
  buildInputs = [ dbus ];

  # crates/vsm/build.rs scrapes `vault --help` at compile time to generate the
  # clap `after_help` text and the completion tree. `vault` is absent from the
  # build sandbox, and the script degrades gracefully to a short pointer plus an
  # empty tree - same as the upstream crane build, which also omits it.

  # `vsm login` shells out to `vault`, which in turn shells out to xdg-open for
  # the OIDC browser callback.
  postInstall = lib.optionalString withVaultWrapper ''
    wrapProgram $out/bin/vsm \
      --prefix PATH : ${lib.makeBinPath [ vault xdg-utils ]}
  '';

  meta = {
    description = "Manage multiple HashiCorp Vault contexts and sessions";
    longDescription = ''
      vsm manages multiple HashiCorp Vault contexts and sessions, injecting the
      active context's VAULT_ADDR / VAULT_TOKEN / VAULT_NAMESPACE into forwarded
      vault invocations.

      It requires the `vault` CLI at runtime. Because Vault is BUSL-1.1 (unfree
      in Nixpkgs) this derivation does not depend on it by default - put `vault`
      on PATH yourself, or build with `.override { withVaultWrapper = true; }`
      under `allowUnfree = true` to bake the dependency in.
    '';
    homepage = "https://github.com/Dauliac/vault-sessions-manager";
    license = with lib.licenses; [ mit asl20 ];
    mainProgram = "vsm";
    maintainers = [ ];
    # Upstream advertises `platforms.unix`, but crates/vsm/Cargo.toml hardcodes
    # the keyring crate's `sync-secret-service` feature, which is a Linux/BSD
    # secret-service backend. Claim only what is actually exercised.
    platforms = lib.platforms.linux;
  };
})
