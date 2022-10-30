{
  openssl,
  nodejs,
}:
if builtins.compareVersions nodejs.version "18" >= 0 && builtins.compareVersions openssl.version "3" >= 0
then "--openssl-legacy-provider"
else ""
