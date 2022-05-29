{ lib
, fetchurl
, symlinkJoin
, buildGoModule
, runCommand
, makeWrapper
, v2ray-geoip
, v2ray-domain-list-community
, assets ? [ v2ray-geoip v2ray-domain-list-community ]
, sources
}:
let
  assetsDrv = symlinkJoin {
    name = "v2ray-assets";
    paths = assets;
  };

  core = buildGoModule rec {
    inherit (sources.v2ray) pname version src;
    vendorSha256 = "sha256-jl0lu9z8wRaqRL4rhlk+VD8FEaJlwvpvoXIfNwOgR2Y=";

    doCheck = false;

    patches = [
      (fetchurl {
        url = "https://github.com/v2fly/v2ray-core/commit/0468cdfa56e625377039fe9b496c892f58df60e7.diff";
        sha256 = "sha256-TmFQmJC75oR2sYkv1JvzoJfekdmWw482CQY4LLR9wdI=";
      })
      (fetchurl {
        url = "https://patch-diff.githubusercontent.com/raw/v2fly/v2ray-core/pull/1771.diff";
        sha256 = "sha256-+JbGF8VZeqXkmo0dxiSFo3kfqbNynzlMwvDRDwpZRlA=";
      })
      (fetchurl {
        url = "https://patch-diff.githubusercontent.com/raw/v2fly/v2ray-core/pull/1772.diff";
        sha256 = "sha256-2QDDMQuAtRMiKgBxIMPZrK9R06OLZbjgZumpjbmNc+s=";
      })
    ];

    buildPhase = ''
      buildFlagsArray=(-v -p $NIX_BUILD_CORES -ldflags="-s -w")
      runHook preBuild
      go build "''${buildFlagsArray[@]}" -o v2ray ./main
      runHook postBuild
    '';

    installPhase = ''
      install -Dm755 v2ray -t $out/bin
    '';

    meta = {
      homepage = "https://www.v2fly.org/en_US/";
      description = "A platform for building proxies to bypass network restrictions";
      license = lib.licenses.mit;
    };
  };
in
runCommand core.name
{
  inherit (core) version meta;
  nativeBuildInputs = [ makeWrapper ];
} ''
  for file in ${core}/bin/*; do
    makeWrapper "$file" "$out/bin/$(basename "$file")" \
      --set-default V2RAY_LOCATION_ASSET ${assetsDrv}/share/v2ray
  done
''
