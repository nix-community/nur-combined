{ self, inputs, ... }:
{
  # Patched Claude Code.
  #
  # The overlay is a separate fixed point (`overlays.clipatch`) instead of an
  # entry in `overlays.default`: the by-name packages in `pkgs/by-name` are
  # callPackage'd from a package set that already has `overlays.default` applied,
  # so overriding claude-code there would make `prev.claude-code` point back at
  # the override itself.
  flake.overlays.clipatch = import ../pkgs/claude-code/overlay.nix;

  # Any host that installs claude-code imports `dev` (via dev-pkgs), so attaching
  # the overlay there keeps every claude-code in the cluster patched without
  # touching each host file. nixpkgs.overlays is an appendable option, so this
  # composes with `modules.nixos.overlay` and the per-host `nixpkgs.overlays`.
  flake.modules.nixos.clipatch =
    {
      config,
      lib,
      ...
    }:
    {
      nixpkgs.overlays = [ self.overlays.clipatch ];

      # claude-code self-updates only when DISABLE_AUTOUPDATER is unset; both
      # nixpkgs and llm-agents.nix set it in their wrapper, but pin it here too
      # so a future wrapper change cannot let the CLI replace the patched binary.
      environment.sessionVariables = lib.mkDefault {
        DISABLE_AUTOUPDATER = "1";
      };
    };

  # claude-code exported as a buildable package, for each source.
  #
  # A nixpkgs overlay only reaches nixpkgs' own claude-code, and it only reaches
  # NixOS hosts that import the clipatch module. These two attributes make the
  # patched CLI addressable from anywhere: `nix run`, `nix build`, another flake,
  # or a remote machine, without needing the overlay or the module.
  #
  # `inputs` here is the flake-parts top-level argument (same idiom as
  # mod/pkgs.nix); the perSystem argument inputs' carries only flake-parts'
  # refined inputs, which has no llm-agents packages.
  perSystem =
    { system, pkgs, ... }:
    let
      # llm-agents' claude-code is built against llm-agents' own nixpkgs, so
      # everything added to it has to come from that same package set. See the
      # glibc note on the patch below.
      llmPkgs = inputs.llm-agents.inputs.nixpkgs.legacyPackages.${system};
      llmClaude = inputs.llm-agents.packages.${system}.claude-code;
    in
    {
      packages.claudeCodePatched = import ../pkgs/claude-code/patchClaude.nix {
        drv = llmClaude.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ llmPkgs.makeWrapper ];

          # CLAUDE_CODE_EXPERIMENTAL_CODE_MODE=1 switches on the CLI's code-mode
          # surface. `--set` (not `--set-default`) is deliberate: the wrapper
          # should pin the flag rather than let an ambient value turn it off.
          #
          # This is a second wrapper layer, which llm-agents' own postFixup warns
          # against for ps/htop readability. It cannot be avoided from outside:
          # upstream's is a single literal `wrapProgram` call, and this nixpkgs'
          # wrapper hooks ignore both `makeWrapperArgs` and `userWrapperArgs`, so
          # there is no hook to add one flag to it. Both layers pass
          # `--argv0 claude`, so the process is still named `claude` in ps.
          postFixup = (old.postFixup or "") + ''
            wrapProgram $out/bin/claude \
              --argv0 claude \
              --set CLAUDE_CODE_EXPERIMENTAL_CODE_MODE 1
          '';
        });
        # The python3 used for the patch has to come from llm-agents' own nixpkgs,
        # not this flake's. llm-agents links the claude binary against its glibc with
        # wrap-buddy (patch_elf), so an extra python3 from a different nixpkgs drags a
        # second glibc into the binary's rpath: two glibcs in one process aborts with
        # "stack smashing detected" before main() runs.
        pkgs = llmPkgs;
      };

      # Same patch on nixpkgs' claude-code. `pkgs.claude-code` here is unpatched:
      # overlays.default does not include clipatch, by design (see the comment on
      # overlays.clipatch above). Do not name this `claude-code`: easyOverlay feeds
      # `config.packages` into overlays.default, and a `claude-code` attribute there
      # would make `prev.claude-code` resolve to the override itself.
      packages.claudeCodeNixpkgsPatched = import ../pkgs/claude-code/patchClaude.nix {
        drv = pkgs.claude-code;
        inherit pkgs;
      };
    };
}
