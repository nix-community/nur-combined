{
  pkgs ? import <nixpkgs> { },
  package ? (import ../../default.nix { inherit pkgs; }).changedetection-io,
}:
let
  reviewedSource = pkgs.fetchFromGitHub {
    owner = "dgtlmoon";
    repo = "changedetection.io";
    tag = "0.60.9";
    hash = "sha256-E7ujQNMG1Qs6NAocAOYP8My8PDfFrI1ejoEIJfvC5VQ=";
  };
  overridden = package.overrideAttrs {
    version = "test-version";
    __intentionallyOverridingVersion = true;
  };
  service =
    (import (pkgs.path + "/nixos/lib/eval-config.nix") {
      inherit pkgs;
      modules = [
        {
          services.changedetection-io = {
            enable = true;
            inherit package;
          };
        }
      ];
    }).config.systemd.services.changedetection-io;
in
assert package.src.tag == package.version;
assert overridden.src.tag == "test-version";
assert
  !pkgs.stdenv.hostPlatform.isLinux
  || pkgs.lib.hasInfix (builtins.unsafeDiscardStringContext "${package}/bin/changedetection.py") service.serviceConfig.ExecStart;
pkgs.runCommand "changedetection-io-dependency-check"
  {
    nativeBuildInputs = [ pkgs.diffutils ];
    PYTHONPATH = "${package}/${pkgs.python3.sitePackages}:${pkgs.python3Packages.makePythonPath package.propagatedBuildInputs}";
  }
  ''
    changed=0
    for file in requirements.txt setup.py; do
      diff -u --label "reviewed/$file" --label "upstream/$file" \
        ${reviewedSource}/"$file" ${package.src}/"$file" || changed=1
    done
    if [ "$changed" != 0 ]; then
      echo "Review upstream dependency changes, adjust the package, then update reviewedSource in tests/pkgs/changedetection-io.nix." >&2
      exit 1
    fi
    export HOME="$TMPDIR"
    ${pkgs.python3.interpreter} - <<'PY'
    import gc
    import tempfile
    from pathlib import Path

    import engineio
    import gevent
    import greenlet
    import orjson
    from lxml import etree
    from pydantic import ValidationError

    from changedetectionio import html_tools
    from changedetectionio.jinja2_custom import unixtime
    from changedetectionio.model.LLMSettings import LLMSettings
    from changedetectionio.processors.restock_diff import Restock
    from jsonpath_ng.ext import parse

    payload = {"prices": [39.99, 1299], "title": "Example"}
    assert orjson.loads(orjson.dumps(payload)) == payload
    assert [match.value for match in parse("$.prices[*]").find(payload)] == payload["prices"]
    assert Restock().parse_currency("39,99") == 39.99
    assert "Example" in html_tools.xpath_filter("//title/text()", "<html><title>Example</title></html>")
    settings = LLMSettings.model_validate({"enabled": False})
    assert settings.model_dump()["enabled"] is False
    try:
        LLMSettings.model_validate({"unknown_setting": True})
    except ValidationError:
        pass
    else:
        raise AssertionError("Unknown LLM settings must be rejected")
    assert greenlet.greenlet(lambda: 42).switch() == 42
    assert gevent.spawn(lambda: 42).get(timeout=5) == 42
    assert gc.isenabled()
    assert engineio.Server(async_mode="threading").async_mode == "threading"
    assert engineio.Server(async_mode="gevent").async_mode == "gevent"
    assert unixtime(1759188682, "%Y-%m-%d", "UTC") == "2025-09-29"
    with tempfile.TemporaryDirectory() as temporary:
        directory = Path(temporary)
        secret = directory / "secret.txt"
        secret.write_text("PACKAGING_TEST_SECRET")
        external = directory / "external.dtd"
        external.write_text(f'<!ENTITY % file SYSTEM "{secret.as_uri()}"><!ENTITY leaked "%file;">')
        xml = f'<!DOCTYPE root [<!ENTITY % dtd SYSTEM "{external.as_uri()}">%dtd;]><root>&leaked;</root>'
        try:
            root = etree.fromstring(xml.encode())
        except etree.XMLSyntaxError:
            pass
        else:
            assert b"PACKAGING_TEST_SECRET" not in etree.tostring(root)
    print("Installed dependency compatibility and XML security checks passed")
    PY
    touch "$out"
  ''
