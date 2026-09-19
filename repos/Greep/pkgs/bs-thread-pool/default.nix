{
  lib,
  stdenv,
  fetchFromGitHub,
  maintainers,
}:

let
  version = "5.1.0";
in

stdenv.mkDerivation {
  pname = "bs-thread-pool";
  inherit version;

  src = fetchFromGitHub {
    owner = "bshoshany";
    repo = "thread-pool";
    tag = "v${version}";
    sha256 = "sha256-/RMo5pe9klgSWmoqBpHMq2lbJsnCxMzhsb3ZPsw3aZw=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 include/BS_thread_pool.hpp -t $out/include

    runHook postInstall
  '';

  meta = with lib; {
    description = "BS::thread_pool: a fast, lightweight, modern, and easy-to-use C++17 / C++20 / C++23 thread pool library";
    homepage = "https://github.com/bshoshany/thread-pool";
    downloadPage = "https://github.com/bshoshany/thread-pool";
    license = licenses.mit;
    platforms = platforms.all;
    changelog = "https://github.com/bshoshany/thread-pool/blob/master/CHANGELOG.md";
    maintainers = with maintainers; [ bensuperpc ];
  };
}