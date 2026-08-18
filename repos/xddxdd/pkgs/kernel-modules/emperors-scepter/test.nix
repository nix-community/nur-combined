{ lib, ... }:
let
  signals = [
    "NeiKos496"
    "PhiLia093"
    "OreXis945"
    "EpieiKeia216"
    "SkeMma720"
    "HubRis504"
    "ApoRia432"
    "PoleMos600"
    "KaLos618"
    "EleOs252"
    "HapLotes405"
    "SkoPeo365"
  ];
  signalList = lib.concatStringsSep " " signals;
in
{
  name = "emperors-scepter";

  nodes.machine =
    { pkgs, ... }:
    let
      kernelPackages = pkgs.linuxPackages_latest;
      emperorsScepter = pkgs.callPackage ./default.nix {
        inherit (kernelPackages) kernel;
      };
    in
    {
      boot.kernelPackages = kernelPackages;
      boot.extraModulePackages = [ emperorsScepter ];
      boot.kernelModules = [ "emperors_scepter" ];

      environment.systemPackages = [ pkgs.procps ];
    };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    signals = "${signalList}".split()
    assert len(signals) == 12

    def assert_all_idle():
        out = machine.succeed("lsmod")
        assert "emperors_scepter" in out
        for name in signals:
            machine.succeed(f"pgrep -x {name}")
            state = machine.succeed(f"ps -o stat= -C {name}").strip()
            assert state.startswith("I"), f"{name}: expected idle, got {state!r}"

    def assert_none_alive():
        assert "emperors_scepter" not in machine.succeed("lsmod")
        for name in signals:
            machine.fail(f"pgrep -x {name}")

    assert_all_idle()

    machine.succeed("rmmod emperors_scepter")
    assert_none_alive()

    machine.succeed("modprobe emperors_scepter")
    assert_all_idle()
  '';
}
