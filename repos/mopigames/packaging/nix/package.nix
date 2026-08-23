# The derivation, shipped through the Nix User Repository (see nur.nix) and
# built from this checkout by the flake at the repository root.
#
# Nothing here is templated, unlike the winget and AUR manifests: NUR
# evaluates this file as it stands at a commit, so the version and hash are
# real values.  `packaging/nix/update.sh <tag>` bumps both, and CI runs it on
# every tag.
{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "mlos-host-utils";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "MopigamesYT";
    repo = "moonlight-os";
    tag = "v${finalAttrs.version}";
    hash = "sha256-//Qzgcf6bJR0Y/P4TlVR+ThgjDazdUccmp6UuFVj4uk=";
  };

  # Where nixpkgs is going, and required of new packages there: the builder
  # gets the attributes as real data structures rather than as shell-mangled
  # strings.  Kept so this file stays droppable into nixpkgs unchanged.
  __structuredAttrs = true;

  # The agent is one directory of a repository that is otherwise an ISO
  # build, so the Go module is not at the root.
  modRoot = "host-utils";

  # Standard library only -- there is no go.sum and nothing to vendor.
  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "USB passthrough agent for the PC you stream from with Moonlight OS";
    longDescription = ''
      The host PC half of USB passthrough for Moonlight OS. Moonlight OS says
      which USB devices are plugged into the thin client; this agent attaches
      them to the machine the game is actually running on, over USB/IP.

      On NixOS, use services.mlos-host-utils rather than `mlos-host-utils
      install`: the imperative installer writes a systemd unit and fetches a
      usbip package, and neither survives the next rebuild.
    '';
    homepage = "https://github.com/MopigamesYT/moonlight-os";
    changelog = "https://github.com/MopigamesYT/moonlight-os/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;
    mainProgram = "mlos-host-utils";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
