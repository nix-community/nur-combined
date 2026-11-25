{
  runCommand,
  fetchurl,
  gnutar,
  gzip,
}:

let
  version = "0.1.0-rc.6";
  standard = fetchurl {
    url = "https://github.com/Zakkaus/doona/releases/download/v${version}/doona-${version}.tar.gz";
    hash = "sha256-FOeFh4BxnuFUv+eiS3JBeFGUd71Z6E4rfVLvq6nSvCc=";
  };
  lite = fetchurl {
    url = "https://github.com/Zakkaus/doona/releases/download/v${version}/doona-lite-${version}.tar.gz";
    hash = "sha256-FYaUKeTgb5GJ/nGMkZYFUQEEtp6VTDdWA6zq5wufqsY=";
  };
in
runCommand "doona-${version}"
  {
    nativeBuildInputs = [
      gnutar
      gzip
    ];
  }
  ''
    mkdir -p "$out/doona" "$out/doona-lite"
    tar -xzf ${standard} -C "$out/doona"
    tar -xzf ${lite} -C "$out/doona-lite"
    rm -rf "$out/doona/fonts" "$out/doona-lite/fonts"
    for edition in doona doona-lite; do
      dir="$out/$edition"
      for file in LICENSE NOTICE THIRD-PARTY-NOTICES.txt $(grep -o 'LICENSES/[A-Za-z0-9.+-]*\.txt' "$dir/NOTICE"); do
        test -s "$dir/$file"
      done
    done
  ''
