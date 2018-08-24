{ stdenv, fetchgit, beam, git
}:

beam.packages.erlang.buildMix rec {
  name = "pleroma";
  version = "0.9.0";

  src = fetchgit {
    url = https://git.pleroma.social/pleroma/pleroma.git;
    rev = "v${version}";
    sha256 = "1k33h3j67ywrmkrjr1hvb53j3zsvszb4rfraak1vsh7jn4j6a0wl";
  };

  nativeBuildInputs = [
    git # used to generate things
  ];
  beamDeps = with beam.packages.erlang; [
    html_sanitize_ex
    cachex
    #calendar # not in pkgs
    gettext
    comeonin
    #jason # not in pkgs
    #cowboy # fails to build
    #phoenix_html # not in pkgs
    #httpoison # fails to build
    credo
    phoenix_pubsub
    #trailing_format_plug # fails to build
    #phoenix # not in pkgs
    #postgrex # not in pkgs
    #phoenix_ecto # not in pkgs
  ];

  meta = {
    broken = true;
    description = "A federated social networking platform";
    license = stdenv.lib.licenses.agpl3;
    homepage = https://pleroma.social;
  };
}
