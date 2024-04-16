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

rec {
  modules = import ./modules;

  # For some reason NUR needs to be passed git-credential-manager explicitly to support self-referencing in passthru.tests
  git-credential-manager = pkgs.callPackage ./pkgs/git-credential-manager { git-credential-manager = git-credential-manager; };
  usbguard-applet-qt = pkgs.callPackage ./pkgs/usbguard-applet-qt { };
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
}
