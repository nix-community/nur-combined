{ stdenv, fetchzip, ... }:
stdenv.mkDerivation rec {
  name = "columns";
  version = "2023-06-16";

  src = fetchzip {
    url = "https://github.com/dwp-forge/columns/archive/refs/tags/v.${version}.zip";
    hash = "sha256-YDWNisvvwt2uuYJUsDrXZIxtoh26SmXUnNmMCPx9OJQ=";
  };
  installPhase = "mkdir -p $out; cp -R * $out/";
}
