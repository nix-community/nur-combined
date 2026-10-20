{
  perSystem =
    { pkgs, lib, ... }:
    let
      openvpnToSingBox = pkgs.writeShellApplication {
        name = "openvpn-to-sing-box";
        runtimeInputs = [ pkgs.python3 ];
        text = ''
          exec python3 ${../scripts/openvpn-to-sing-box.py} "$@"
        '';
      };
    in
    {
      apps.openvpn-to-sing-box = {
        type = "app";
        program = lib.getExe openvpnToSingBox;
        meta.description = "Convert an OpenVPN profile to a sing-box JSON overlay offline";
      };
    };
}
