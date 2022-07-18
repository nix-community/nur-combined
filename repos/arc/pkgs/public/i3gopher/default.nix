{ buildGoModule, fetchFromGitHub, makeWrapper, lib
, i3, enableI3 ? true
, sway, enableSway ? hostPlatform.isLinux
, hostPlatform
}: lib.drvExec "bin/i3gopher" (buildGoModule rec {
  pname = "i3gopher";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "quite";
    repo = "i3gopher";
    rev = "v${version}";
    sha256 = "sha256-H/fhIjJ2FV2diTMt1Hf9OTLLmdd5+4y9UC1Q6Fjr2OQ=";
  };

  vendorSha256 = "sha256-DedUQXMA1V2vrLuUWHIABvtIaj2yeC9Uo5Xr6Mc0uvw=";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = lib.optional enableI3 i3 ++ lib.optional enableSway sway;
  i3Path = lib.makeBinPath buildInputs;
  preFixup = ''
    wrapProgram $out/bin/i3gopher --prefix PATH : $i3Path
  '';

  meta = {
    platforms = lib.platforms.linux;
  };
})
