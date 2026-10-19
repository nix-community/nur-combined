{ inputs, pkgs, system }:
let
  computer = inputs.computer-use.packages.${system};
  fingerprint = inputs.gxfp5130Chicago.packages.${system};
in
{
  dms-xhup = inputs.dms-xhup.packages.${system}.default.overrideAttrs (old: {
    meta = old.meta // { homepage = "https://github.com/lihaoze123/dms-xhup"; };
  });
  edunet = inputs.edunet.packages.${system}.edunet.overrideAttrs (old: {
    meta = old.meta // { homepage = "https://github.com/lihaoze123/hhu-edunet-cli"; };
  });
  codex-desktop = computer.codex-desktop.overrideAttrs (old: {
    meta = old.meta // { sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ]; };
  });
  codex-computer-use = computer.codex-computer-use.overrideAttrs (old: {
    meta = (old.meta or { }) // {
      description = "MCP launcher for Codex Computer Use on niri";
      homepage = "https://github.com/lihaoze123/niri-computer-use";
      license = pkgs.lib.licenses.mit;
      mainProgram = "codex-computer-use";
      platforms = [ "x86_64-linux" ];
    };
  });
  codex-computer-use-niri = computer.codex-computer-use-niri.overrideAttrs (old: {
    meta = (old.meta or { }) // {
      description = "Native Codex Computer Use backend patched for niri";
      homepage = "https://github.com/lihaoze123/niri-computer-use";
      license = pkgs.lib.licenses.mit;
      mainProgram = "codex-computer-use-linux";
      platforms = [ "x86_64-linux" ];
    };
  });
  inherit (computer) niri-patched;
  gxfp5130-fprintd = fingerprint.fprintd.overrideAttrs (old: {
    meta = old.meta // { maintainers = [ ]; };
  });
  gxfp5130-libfprint = fingerprint.libfprint;
  gxfp5130-tools = fingerprint.tools.overrideAttrs (old: {
    meta = (old.meta or { }) // {
      description = "Native ChicagoHS fingerprint enrollment and verification tools";
      homepage = "https://github.com/lihaoze123/gxfp5130-chicago";
      license = pkgs.lib.licenses.mit;
      mainProgram = "gxfp-chicago-verify";
      platforms = [ "x86_64-linux" ];
    };
  });
}
