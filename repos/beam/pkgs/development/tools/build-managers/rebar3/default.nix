{ stdenv, fetchFromGitHub, fetchHex, fetchpatch, erlang, tree }:

let
  version = "3.15.1";

  bbmustache = fetchHex {
    pkg = "bbmustache";
    version = "1.10.0";
    sha256 = "43EFFA3FD4BB9523157AF5A9E2276C493495B8459FC8737144AA186CB13CE2EE";
  };
  certifi = fetchHex {
    pkg = "certifi";
    version = "2.5.3";
    sha256 = "ED516ACB3929B101208A9D700062D520F3953DA3B6B918D866106FFA980E1C10";
  };
  cf = fetchHex {
    pkg = "cf";
    version = "0.3.1";
    sha256 = "315E8D447D3A4B02BCDBFA397AD03BBB988A6E0AA6F44D3ADD0F4E3C3BF97672";
  };
  cth_readable = fetchHex {
    pkg = "cth_readable";
    version = "1.5.1";
    sha256 = "686541A22EFE6CA5A41A047B39516C2DD28FB3CADE5F24A2F19145B3967F9D80";
  };
  erlware_commons = fetchHex {
    pkg = "erlware_commons";
    version = "1.4.0";
    sha256 = "185ECF5CF43BAB3A013DDB3614CE7BBA7F6C7A827904E64E57DA54FCDFDCE2E6";
  };
  eunit_formatters = fetchHex {
    pkg = "eunit_formatters";
    version = "0.5.0";
    sha256 = "D6C8BA213424944E6E05BBC097C32001CDD0ABE3925D02454F229B20D68763C9";
  };
  getopt = fetchHex {
    pkg = "getopt";
    version = "1.0.1";
    sha256 = "53E1AB83B9CEB65C9672D3E7A35B8092E9BDC9B3EE80721471A161C10C59959C";
  };
  parse_trans = fetchHex {
    pkg = "parse_trans";
    version = "3.3.1";
    sha256 = "07CD9577885F56362D414E8C4C4E6BDF10D43A8767ABB92D24CBE8B24C54888B";
  };
  providers = fetchHex {
    pkg = "providers";
    version = "1.8.1";
    sha256 = "E45745ADE9C476A9A469EA0840E418AB19360DC44F01A233304E118A44486BA0";
  };
  relx = fetchHex {
    pkg = "relx";
    version = "4.4.0";
    sha256 = "55C0ED63BB5D55EB983A19EB94D7F3075DF6D126DBDFF43102A6660A91FCE925";
  };
  ssl_verify_fun = fetchHex {
    pkg = "ssl_verify_fun";
    version = "1.1.6";
    sha256 = "BDB0D2471F453C88FF3908E7686F86F9BE327D065CC1EC16FA4540197EA04680";
  };

in stdenv.mkDerivation rec {
  pname = "rebar3";
  inherit version erlang;

  src = fetchFromGitHub {
    owner = "erlang";
    repo = pname;
    rev = version;
    sha256 = "sha256:1pcy5m79g0l9l3d8lkbx6cq1w87z1g3sa6wwvgbgraj2v3wkyy5g";
  };

  bootstrapper = ./rebar3-nix-bootstrap;

  buildInputs = [ erlang tree ];

  postPatch = ''
    mkdir -p _checkouts
    mkdir -p _build/default/lib/
    cp --no-preserve=mode -R ${bbmustache} _checkouts/bbmustache
    cp --no-preserve=mode -R ${certifi} _checkouts/certifi
    cp --no-preserve=mode -R ${cf} _checkouts/cf
    cp --no-preserve=mode -R ${cth_readable} _checkouts/cth_readable
    cp --no-preserve=mode -R ${erlware_commons} _checkouts/erlware_commons
    cp --no-preserve=mode -R ${eunit_formatters} _checkouts/eunit_formatters
    cp --no-preserve=mode -R ${getopt} _checkouts/getopt
    cp --no-preserve=mode -R ${parse_trans} _checkouts/parse_trans
    cp --no-preserve=mode -R ${providers} _checkouts/providers
    cp --no-preserve=mode -R ${relx} _checkouts/relx
    cp --no-preserve=mode -R ${ssl_verify_fun} _checkouts/ssl_verify_fun
    # Bootstrap script expects the dependencies in _build/default/lib
    # TODO: Make it accept checkouts?
    for i in _checkouts/* ; do
        ln -s $(pwd)/$i $(pwd)/_build/default/lib/
    done
  '';

  buildPhase = ''
    HOME=. escript bootstrap
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp rebar3 $out/bin/rebar3
  '';

  meta = {
    homepage = "https://github.com/rebar/rebar3";
    description =
      "Erlang build tool that makes it easy to compile and test Erlang applications, port drivers and releases";

    longDescription = ''
      rebar is a self-contained Erlang script, so it's easy to distribute or
      even embed directly in a project. Where possible, rebar uses standard
      Erlang/OTP conventions for project structures, thus minimizing the amount
      of build configuration work. rebar also provides dependency management,
      enabling application writers to easily re-use common libraries from a
      variety of locations (hex.pm, git, hg, and so on).
    '';

    platforms = stdenv.lib.platforms.unix;
    maintainers = with stdenv.lib.maintainers; [ gleber tazjin ];
    license = stdenv.lib.licenses.asl20;
  };
}
