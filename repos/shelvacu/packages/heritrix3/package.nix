{ fetchFromGitHub, maven }:
maven.buildMavenPackage rec {
  pname = "heritrix3";
  version = "3.14.1";

  src = fetchFromGitHub {
    owner = "internetarchive";
    repo = "heritrix3";
    tag = version;
    hash = "sha256-EP8U3BjnQAmrqcb6xs6GzsM0MqkQi81vJM+VxtGXHeM=";
  };

  patches = [ ./disable-failing-tests.patch ];

  mvnHash = "sha256-U+KFAMQ3amAywl6oxlqyHB3FZQaWDoRdR4qDGrLzrY0=";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share

    dist_tar="$PWD"/dist/target/heritrix-${version}-dist.tar.gz

    if [[ ! -f $dist_tar ]]; then
      echo "ERR: could not find dist tar" >&2
      exit 1
    fi

    extract_temp="$(mktemp -d)"
    tar -xf "$dist_tar" -C "$extract_temp"
    mv "$extract_temp/heritrix-${version}" "$out/share/heritrix3"
    rm "$out/share/heritrix3/bin/"*.cmd

    runHook postInstall
  '';

  meta = {
    description = "Extensible, archive-quality web crawler by Internet Archive";
    homepage = "https://heritrix.readthedocs.io/";
  };
}
