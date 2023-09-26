{ pkgs, config, lib, ... }:

let
  cfg = config.mloeper.aws-localproxy;
  aws-iot-securetunneling-localproxy = pkgs.callPackage ./../pkgs/aws-iot-securetunneling-localproxy { };
in
{
  options.mloeper.aws-localproxy.enable = lib.mkEnableOption "Enable aws-localproxy";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      aws-iot-securetunneling-localproxy
    ];

    # note: this might not be necessary as Amazon Root CA 1 is included in cacert
    security.pki.certificateFiles = [ "${pkgs.aws-iot-securetunneling-localproxy}/share/certs/AmazonRootCA1.pem" ];
  };
}
