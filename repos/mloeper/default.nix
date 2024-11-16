# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { }
, ...
}:

let
  mloeper = {
    name = "Martin Löper";
    email = "martin.loeper@nesto-software.de";
    github = "MartinLoeper";
    githubId = 5209395;
  };
in
rec {
  modules = import ./modules;
  usbguard-applet-qt = pkgs.callPackage ./pkgs/usbguard-applet-qt { };
  knockd = pkgs.callPackage ./pkgs/knockd { };
  dashlane-cli = pkgs.callPackage ./pkgs/dashlane-cli { };
  devcontainer-cli-unofficial = pkgs.callPackage ./pkgs/devcontainer-cli-unofficial { };
  glib = pkgs.callPackage ./pkgs/glib { };
  mingo = pkgs.callPackage ./pkgs/mingo { };
  mkusb-nox = pkgs.callPackage ./pkgs/mkusb-nox { };
  mkusb-plug = pkgs.callPackage ./pkgs/mkusb-plug { };
  mkusb-sedd = pkgs.callPackage ./pkgs/mkusb-sedd { };
  xorriso = pkgs.callPackage ./pkgs/xorriso { };
  dynobase = pkgs.callPackage ./pkgs/dynobase { };
  aws-iot-securetunneling-localproxy = pkgs.callPackage ./pkgs/aws-iot-securetunneling-localproxy { protobuf3_19 = protobuf3_19; };
  elster-authenticator = pkgs.callPackage ./pkgs/elster-authenticator { };
  lightdm-webkit2-greeter = pkgs.callPackage ./pkgs/lightdm-webkit2-greeter { lightdm-webkit2-greeter = lightdm-webkit2-greeter; };
  protobuf3_19 = pkgs.callPackage ./pkgs/protobuf3_19/default.nix {
    abseil-cpp = pkgs.abseil-cpp_202103;
  };
  firefox-addons = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/firefox-addons { });
  mongosh = pkgs.callPackage ./pkgs/mongosh { };
  atlas-cli = pkgs.callPackage ./pkgs/atlas-cli { };
  nosql-workbench = pkgs.callPackage ./pkgs/nosql-workbench { };
  s3-browser-cli = pkgs.callPackage ./pkgs/s3-browser-cli/pkgs { };
  openvpn3 = pkgs.callPackage ./pkgs/openvpn3 { };
  openvpn3-indicator = pkgs.callPackage ./pkgs/openvpn3-indicator {
    openvpn3 = openvpn3; # we use our custom openvpn3 package which is a bump v20 -> v21
  };
  nodejs_20_11_1 = pkgs.callPackage ./pkgs/nodejs { };
  cli-microsoft365 = pkgs.callPackage ./pkgs/cli-microsoft365 { };
  m365 = cli-microsoft365; # alias for cli-microsoft365
  postman-cli = pkgs.callPackage ./pkgs/postman-cli {
    inherit mloeper;
  };
  #rancher-desktop = pkgs.callPackage ./pkgs/rancher-desktop { };
  jetbrains = {
    gateway = (pkgs.callPackages ./pkgs/jetbrains {
      vmopts = null;
      jdk = pkgs.jetbrains.jdk;
    }).gateway;
    pycharm-professional = (pkgs.callPackages ./pkgs/jetbrains {
      vmopts = null;
      jdk = pkgs.jetbrains.jdk;
    }).pycharm-professional;
  };
  aptakube = pkgs.callPackage ./pkgs/aptakube { };
}
