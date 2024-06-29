{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "vanity-imports";
  version = "0.0.12";

  src = fetchFromGitHub {
    owner = "mlcdf";
    repo = "vanity-imports";
    rev = "v${version}";
    hash = "sha256-4JoJL079hBkwWVvOTRbCM1WZhM7hPlKQ+HEAUr7fWP8=";
  };

  vendorHash = "sha256-w0LaXevbGm1xpHvKxxyubHCOVRN712UzLyOd+hVikKg=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Use a custom domain in your Go import path";
    homepage = "https://github.com/mlcdf/vanity-imports";
    license = licenses.mit;
    maintainers = with maintainers; [ alanpearce ];
    mainProgram = "vanity-imports";
  };
}
