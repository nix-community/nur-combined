{
  lib,
  stdenv,
  fetchFromGitHub,
  maintainers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zpp-bits";
  version = "4.7.6";

  src = fetchFromGitHub {
    owner = "eyalz800";
    repo = "zpp_bits";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SEWoa+qKHE/oN8JXyC/Y1WYbD8ljCTQOAQKIrDc1X/w=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 zpp_bits.h -t $out/include

    runHook postInstall
  '';

  meta = with lib; {
    description = "Modern C++20 binary serialization and RPC library";
    homepage = "https://github.com/eyalz800/zpp_bits";
    changelog = "https://github.com/eyalz800/zpp_bits/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = platforms.all;
    maintainers = with maintainers; [ bensuperpc ];
  };
})
