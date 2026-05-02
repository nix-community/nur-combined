# Prisma engines pinned to the exact commit expected by `prisma-client-py` 0.15.0
# (the version of `prisma` shipped in nixpkgs).
#
# Why a custom derivation instead of pkgs.prisma-engines_{6,7}:
#   prisma-client-py 0.15.0 hardcodes engine commit
#   `393aa359c9ad4a4bb28630fb5613f9c281cde053` (Prisma 5.17.0). Pointing
#   PRISMA_QUERY_ENGINE_BINARY at v6/v7 engines causes wire-protocol
#   mismatches (especially for `schema-engine` during migrations). The
#   prisma-client-py project is unmaintained (last release Sep 2024), so
#   we must match its expected engine version exactly.
#
# We download the official prebuilt binaries from binaries.prisma.sh
# (fixed-output, content-addressed). This avoids a multi-hour Rust build
# in CI for what is otherwise a stable, well-tested artifact.

{
  lib,
  stdenvNoCC,
  fetchurl,
  gzip,
  autoPatchelfHook,
  openssl,
  zlib,
  stdenv,
}:

let
  engineVersion = "393aa359c9ad4a4bb28630fb5613f9c281cde053";
  prismaVersion = "5.17.0";

  # platform → { binarySuffix, hashes }
  platformMap = {
    "x86_64-linux" = {
      suffix = "debian-openssl-3.0.x";
      hashes = {
        query-engine = "sha256-m8hX3r4NV2DFce5icQdiI9lL6YHCmiJAHeaB8/cOBn0=";
        schema-engine = "sha256-mK1DP9ZNouoettVlVTqaQzns8w8cIRsotpaQ9ZEmmkE=";
        libquery_engine = "sha256-El11c5vX/NuOq7VCg1W1vgD1QAQ+a8H1swJolHr6sb0=";
        prisma-fmt = "sha256-5r8j2x5/5FauFn9HRKcd+tkHVyfObQ9lWCpb7l/oeT8=";
      };
    };
    "aarch64-linux" = {
      suffix = "linux-arm64-openssl-3.0.x";
      hashes = {
        query-engine = "sha256-NlQlgnjHsYEsDHopmt0XdxQaKYtuu3LqvbXK04oOjSA=";
        schema-engine = "sha256-aAH6ieyw7xq+ncAkcmH/m0fKqw7SjyIp4KKJ7+Fk+NA=";
        libquery_engine = "sha256-e+tbmENzxMkFkSO+gHY7iNdA9d6gjtoSPP17zawQflU=";
        prisma-fmt = "sha256-uzT0GSWaB4kc/mm4LXM6V4C9iIS02Vg2pbkCmcIoKE4=";
      };
    };
  };

  plat = platformMap.${stdenv.hostPlatform.system} or (throw
    "prisma-engines_5_17: unsupported platform ${stdenv.hostPlatform.system}");

  fetchEngine = name:
    fetchurl {
      url = "https://binaries.prisma.sh/all_commits/${engineVersion}/${plat.suffix}/${name}.gz";
      hash = plat.hashes.${lib.removeSuffix ".so.node" name};
    };

  # libquery_engine has a different filename pattern
  fetchLibEngine = fetchurl {
    url = "https://binaries.prisma.sh/all_commits/${engineVersion}/${plat.suffix}/libquery_engine.so.node.gz";
    hash = plat.hashes.libquery_engine;
  };
in

stdenvNoCC.mkDerivation {
  pname = "prisma-engines_5_17";
  version = prismaVersion;

  dontUnpack = true;

  nativeBuildInputs = [
    gzip
    autoPatchelfHook
  ];

  buildInputs = [
    openssl
    zlib
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib

    install_engine() {
      local name=$1 src=$2 dst=$3
      gzip -dc "$src" > "$dst"
      chmod +x "$dst"
    }

    install_engine query-engine ${fetchEngine "query-engine"} $out/bin/query-engine
    install_engine schema-engine ${fetchEngine "schema-engine"} $out/bin/schema-engine
    install_engine prisma-fmt ${fetchEngine "prisma-fmt"} $out/bin/prisma-fmt

    gzip -dc ${fetchLibEngine} > $out/lib/libquery_engine.node
    chmod 0644 $out/lib/libquery_engine.node

    runHook postInstall
  '';

  # The setup hook exports the env vars that prisma-client-py and the
  # `prisma` CLI inspect at runtime to skip downloading engines.
  setupHook = ./prisma-engines-hook.sh;

  passthru = {
    inherit engineVersion prismaVersion;
  };

  meta = {
    description = "Prisma engines (query/schema/fmt) pinned to v5.17.0 commit ${engineVersion}";
    homepage = "https://github.com/prisma/prisma-engines";
    license = lib.licenses.asl20;
    platforms = lib.attrNames platformMap;
    maintainers = with lib.maintainers; [ codgician ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
