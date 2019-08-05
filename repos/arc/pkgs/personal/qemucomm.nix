{ wrapShellScriptBin, fetchFromGitHub, coreutils, jq, socat ? null, netcat-gnu ? null }:
assert socat != null || netcat-gnu != null;
let
  netcat-gnu' = if socat == null then netcat-gnu else null;
  rev = "30c4beb54866145d99733c89661c152c84901e15";
  src = fetchFromGitHub {
    inherit rev;
    owner = "arcnmx";
    repo = "qemucomm";
    sha256 = "1bi6990zsxzljsd2mxkwav3zd224w32is9l5g6sxynbl0b02ngnc";
  };
in
wrapShellScriptBin "qemucomm" src {
  depsRuntimePath = [coreutils jq socat netcat-gnu'];
  name = "qemucomm-${rev}";
  version = rev;
  source = "${src}/qemucomm";
}
