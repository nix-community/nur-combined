{ buildGoModule, fetchFromGitHub, makeWrapper, lib
, i3, enableI3 ? true
, sway, enableSway ? hostPlatform.isLinux
, hostPlatform
}: lib.drvExec "bin/i3gopher" (buildGoModule rec {
  pname = "i3gopher";
  version = "2020-09-02";

  src = fetchFromGitHub {
    owner = "quite";
    repo = "i3gopher";
    rev = "d8ac71f6499d0d15dd011c49522efab14d599dff";
    sha256 = "04qz33vb7cvg6ckg7c04x170d992z55n3mncjyj72bc1d02hplh9";
  };

  vendorSha256 = "1v11zmazk9aplskkr7gslzni6klfwadyi6kgazjyh3zl97wf6bb4";

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
