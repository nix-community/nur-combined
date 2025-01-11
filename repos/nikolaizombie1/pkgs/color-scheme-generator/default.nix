{
  rustPlatform,
  fetchFromGitHub,
  lib,
  openssl,
  sqlite,
  pkg-config,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  name = "color-scheme-generator";
  preferLocalBuild = true;

  src = fetchFromGitHub {
    owner = "nikolaizombie1";
    repo = "color_scheme_generator";
    rev = "v1.0.0";
    hash = "sha256-qXo2psBRs1bN5LOGFH7xGvxiWOoeTcYALOYjN9Dkpqo=";
  };

  cargoHash = "sha256-i2btJLH9FVkvy2/3+2jkmiIFGOQxX5XctQVb31AVyPg=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    sqlite
  ];

  env = {
    OPENSSL_NO_VENDOR = 1;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Image-based color scheme generator for Waybar";
    longDescription = ''
      color_scheme_generator is a command line utility used to analyze images and generate color themes from them given a path to an image.
      This command line utility behaves like a standard UNIX utility where the path to the image can be either piped in or sent a command line argument.
      The intended purpose of this application is to automatically create color themes for Waybar, but it can be used for the bar in AwesomeWM or other applications to theme based on the on an image. This utility has a cache for the image analysis. This means that once an image has been analyzed once, the result will be saved in the cache and when an image is analyzed again, the results will be returned instantly
    '';
    homepage = "https://github.com/nikolaizombie1/color_scheme_generator";
    changelog = "https://github.com/nikolaizombie1/color_scheme_generator/releases/tag/v1.0.0";
    license = lib.licenses.gpl3Plus;
  };
}
