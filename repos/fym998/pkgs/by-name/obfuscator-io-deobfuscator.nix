{
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
}:
buildNpmPackage (finalAttrs: {
  pname = "obfuscator-io-deobfuscator";
  version = "unstable-2025-03-27";

  src = fetchFromGitHub {
    owner = "ben-sb";
    repo = "obfuscator-io-deobfuscator";
    rev = "443e8855bc75749aa49e59de6f14d571f6f07508";
    hash = "sha256-QOf5dZCDbm/F11OjVxArAmnVfkSEQsBXId8GGe8Cs5o=";
  };

  nodejs = nodejs_22;

  npmDepsHash = "sha256-WuTuJ5s+lE2R7q4r0H1HEFSDSP0Suopc4alt2Z/MGsk=";
  npmBuildScript = "prepare";

  meta = {
    description = "Obfuscator.io deobfuscator";
    homepage = "https://github.com/ben-sb/obfuscator-io-deobfuscator";
    inherit (finalAttrs.nodejs.meta) platforms;
  };
})
