{ stdenv
, fetchFromGitHub
, rustPlatform
, llvm_11
, zlib
, ncurses
, libxml2
}:

rustPlatform.buildRustPackage rec {
  pname = "bpf-linker";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "alessandrod";
    repo = pname;
    rev = "v${version}";
    sha256 = "10dvnaxc0zslw083fx7lm68wiilk8zc1k6lv8y1k564slqjrlwrm";
  };

  cargoSha256 = "1hsv7n27yrax5zaxhkjrcjfkvhvggibc6rdhn4d9li2pwkja43mw";

  nativeBuildInputs = [
    llvm_11
  ];
  buildInputs = [
    zlib
    ncurses
    libxml2
  ];

  doCheck = false;
  doInstallCheck = true;
  installCheckPhase = ''
    if [[ "$("$out/bin/${pname}" --version)" == "${pname} ${version}" ]]; then
      $out/bin/${pname} --help | grep -q ${pname} 
      echo '${pname} smoke check passed'
    else
      echo '${pname} smoke check failed'
      return 1
    fi
  '';

  meta = with stdenv.lib; {
    description = "An BPF Linker written in Rust";
    homepage = "https://github.com/alessandrod/bpf-linker";
    license = [ licenses.asl20 licenses.mit ];
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.linux;
  };
}
