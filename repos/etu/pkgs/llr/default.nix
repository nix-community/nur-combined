{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}: let
  pname = "llr";
  version = "0.9.2";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "etu";
      repo = pname;
      rev = version;
      hash = "sha256-VjHDDIXPWX+3GK1tIZnJpB2R1MoYSNqNBhNf3UmXE4c=";
    };

    vendorHash = "sha256-rGlO/dO7uNwBeC0zTfWHgyz+E9vlOylyJqzunUJ1cAw=";

    meta = with lib; {
      description = "llr reads text and truncates it to the terminal width";
      homepage = "https://github.com/etu/${pname}";
      changelog = "https://github.com/etu/${pname}/releases/tag/${version}";
      license = licenses.isc;
      maintainers = [maintainers.etu];
      platforms = platforms.all;
    };
  }
