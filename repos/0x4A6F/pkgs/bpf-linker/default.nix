{ stdenv
, lib
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

  cargoSha256 = "16vq9zgxpxb2zxxwn5h6qvdk71hfzhjy1sja5msfmrxhys8znk9y";

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

  meta = with lib; {
    description = "An BPF Linker written in Rust";
    homepage = "https://github.com/alessandrod/bpf-linker";
    license = [ licenses.asl20 licenses.mit ];
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.linux;
  };
}
