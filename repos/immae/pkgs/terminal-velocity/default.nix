{ python36Packages }:
with python36Packages;
buildPythonApplication rec {
  pname = "terminal-velocity-git";
  version = "0.2.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "13yrkcmvh5h5fwnai61sbmqkrjyisz08n62pq0ada2lyyqf7g6b9";
  };

  patches = [
    ./sort_found_notes.patch
    ./python3_support.patch
    # FIXME: update this patch when version changes
    ./fix_build.patch
  ];

  preCheck = ''
    # Needed for urwid test
    export LC_ALL=en_US.UTF-8
    '';
  propagatedBuildInputs = [
    chardet
    urwid
    (sh.overridePythonAttrs { doCheck = false; })
    pyyaml
  ];
  buildInputs = [
    m2r
    (restructuredtext_lint.overridePythonAttrs { doCheck = false; })
    pygments
  ];

  postInstall = ''
    rm $out/bin/terminal_velocity
    '';
}
