{ callPackage, pkgs }:

{
  aws-cdk-local = callPackage ./aws-cdk-local { };

  awscli-local = callPackage ./awscli-local { };

  python-barbicanclient = pkgs.python3Packages.callPackage ./python-barbicanclient { };

  python-designateclient = pkgs.python3Packages.callPackage ./python-designateclient { };

  shadow-prod = callPackage ./shadow-client {
    channel = "prod";
    enableDiagnostics = true;
    enableDesktopLauncher = true;
  };

  shadow-preprod = callPackage ./shadow-client {
    channel = "preprod";
    enableDiagnostics = true;
    enableDesktopLauncher = true;
  };

  shadow-testing = callPackage ./shadow-client {
    channel = "testing";
    enableDiagnostics = true;
    enableDesktopLauncher = true;
  };

  terraform-local = callPackage ./terraform-local { };
}
