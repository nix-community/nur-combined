{
  maintainers,
  lib,
  fetchFromGitLab,
  buildDotnetModule,
  msbuild,
  nuget,
  ...
}:
let
  pname = "Binah";
  version = "2.0.4";

  rev = "v${version}";
  gitHash = "18b031f4ecc538832b4f3c44a78dd2e450acba9b";
  hash = "sha256-Avk2pVVbuXKCTxybBb5DP1dY6EQmIUhU8e6+s3tyVek=";
in
buildDotnetModule {
  inherit pname version;

  src = fetchFromGitLab {
    inherit hash rev;
    owner = "wolfre";
    repo = "binah";
  };

  projectFile = "Binah.sln";
  disabledTests = true;

  nativeBuildInputs = [
    msbuild
    nuget
  ];

  postPatch = ''
    substituteInPlace BuildInfo.cs \
      --replace-fail "AssemblyVersion(\"0.0.0.0\")" "AssemblyVersion(\"${version}.0\")" \
      --replace-fail "AssemblyFileVersion(\"0.0.0.0\")" "AssemblyFileVersion(\"${version}.0\")" \
      --replace-fail "AssemblyInformationalVersion(\"0.0.0\")" "AssemblyInformationalVersion(\"${version}\")" \
      --replace-fail "GitCommit = \"0000000000000000000000000000000000000000\"" "GitCommit = \"${gitHash}\"" \
      --replace-fail "GitCommitShort = \"00000000\"" "GitCommitShort = \"${builtins.substring 0 8 gitHash}\"" \
      --replace-fail "BuildInfo = \"info about this build\"" "BuildInfo = \"nixpkgs (JuniorIsAJitterbug/nur-packages)\""
  '';

  buildPhase = ''
    msbuild \
      -target:Binah \
      -p:Configuration=Release \
      -p:TargetFrameworkVersion=v4.5
  '';

  installPhase = ''
    nuget pack "Binah.nuspec" -Version ${version} -OutputDirectory "$out"
  '';

  meta = {
    inherit maintainers;
    description = "An extendable .NET command line parser with building blocks.";
    homepage = "https://gitlab.com/wolfre/binah";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
  };
}
