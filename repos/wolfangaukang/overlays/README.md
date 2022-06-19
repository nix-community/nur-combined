# Some observations here

Here are some examples of overlays:

```nix
final: prev:
{
  # Running chromium browser on incognito
  chromium = prev.chromium.override {
    commandLineArgs = "--incognito";
  };

  # Replace version
  upwork = prev.upwork.overrideAttrs ( old: rec {
    version = "5.6.7.13";
    src = prev.fetchurl {
      url = "https://upwork-usw2-desktopapp.upwork.com/binaries/v5_6_7_13_9f0e0a44a59e4331/upwork_${version}_amd64.deb";
      sha256 = "f1d3168cda47f77100192ee97aa629e2452fe62fb364dd59ad361adbc0d1da87";
    };
  });

  # Calling a package 
  upwork = prev.callPackage ../pkgs/upwork { };

  # Using an input to extract packages
  unstable = import inputs.nixpkgs-unstable {
    system = prev.system;
    config.allowUnfree = true;
  };
}
```
