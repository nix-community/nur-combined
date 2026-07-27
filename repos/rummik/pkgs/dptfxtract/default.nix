{ stdenv, fetchFromGitHub, autoPatchelfHook }:

stdenv.mkDerivation rec {
  pname = "dptfxtract";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "dptfxtract";
    rev = "v${version}";
    sha256 = "1hf1wf66ga5147f4qh0jpvmyhnmigynxrxsh22kl9qanqdl07gnn";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = /* sh */ ''
    mkdir -p $out/sbin
    chmod +x dptfxtract
    cp dptfxtract $out/sbin
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/intel/dptfxtract/;
    description = "Linux DPTF Extract Utility";
    platforms = platforms.linux;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [ rummik ];
  };
}
