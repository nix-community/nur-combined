{
  maintainers,
  lib,
  fetchFromGitLab,
  buildDotnetModule,
  msbuild,
  nuget,
  mono,
  binah,
  ...
}:
let
  pname = "vhs-decode-auto-audio-align";
  version = "1.0.2";
  semVer = lib.splitVersion version;

  rev = "v${version}";
  gitHash = "1790365e9561e6ab9cc8594cc560e76dc8da79a3";
  hash = "sha256-/7uyi/cGVuSV3598kp/+varkh8ybFimqepwZaGy07zA=";
in
buildDotnetModule {
  inherit pname version;

  src = fetchFromGitLab {
    inherit hash rev;
    owner = "wolfre";
    repo = "vhs-decode-auto-audio-align";
  };

  projectFile = "VhsDecodeAutoAudioAlign.sln";

  nativeBuildInputs = [
    msbuild
    nuget
  ];

  projectReferences = [
    binah
  ];

  postPatch = ''
    substituteInPlace "VhsDecodeAutoAudioAlign/BuildInfo.cs" \
      --replace-fail "Commit = \"0000000000000000000000000000000000000000\"" "Commit = \"${gitHash}\"" \
      --replace-fail "CommitShort = \"00000000\"" "CommitShort = \"${builtins.substring 0 8 gitHash}\"" \
      --replace-fail "BuildJob = \"https://example.com/job/1234\"" "BuildJob = \"nixpkgs (JuniorIsAJitterbug/nur-packages)\"" \
      --replace-fail "BuildTime = \"0000-00-00T00:00:00+00:00\"" "BuildTime = \"1970-01-01T00:00:00+00:00\"" \
      --replace-fail "VersionMajor = \"0\"" "VersionMajor = \"${builtins.elemAt semVer 0}\"" \
      --replace-fail "VersionMinor = \"0\"" "VersionMinor = \"${builtins.elemAt semVer 1}\"" \
      --replace-fail "VersionPatch = \"0\"" "VersionPatch = \"${builtins.elemAt semVer 2}\"" \
      --replace-fail "VersionSemantic = \"0.0.0\"" "VersionSemantic = \"${version}\""
  '';

  buildPhase = ''
    nuget source Add -Name local -Source "${binah.out}"
    nuget restore VhsDecodeAutoAudioAlign/packages.config -PackagesDirectory "/build/source/packages"

    msbuild \
      -target:VhsDecodeAutoAudioAlign \
      -p:Configuration=Release \
      -p:TargetFrameworkVersion=v4.7.2
  '';

  installPhase = ''
    install -m755 -D build/VhsDecodeAutoAudioAlign.exe $out/bin/VhsDecodeAutoAudioAlign.exe
    install -m755 -D build/Binah.dll $out/bin/Binah.dll

    makeWrapper \
      "${mono}/bin/mono" \
      "$out/bin/VhsDecodeAutoAudioAlign" \
      --add-flags "$out/bin/VhsDecodeAutoAudioAlign.exe"
  '';

  meta = {
    inherit maintainers;
    description = "A project to automatically align synchronous (RF) HiFi and linear audio captures to a video RF capture for VHS-Decode.";
    homepage = "https://gitlab.com/wolfre/vhs-decode-auto-audio-align";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "VhsDecodeAutoAudioAlign";
  };
}
