{ stdenv, lib, fetchFromGitHub, buildPythonPackage
, jsonpatch
, jsonpath_rw
, jsonpointer
, urllib3
}:
buildPythonPackage rec {
  pname = "python-ilorest-library";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "HewlettPackard";
    repo = pname;
    rev = "${version}";
    hash = "sha256:0px03kazdvzx79vjs2zv0j91iylc9gvbv2hwpwgziqv8j3sd68jn";
  };

  propagatedBuildInputs = [
    jsonpatch
    jsonpath_rw
    jsonpointer
    urllib3
  ];
  # For some features it needs ilorest_chif.so, which is proprietary but available here:
  # https://downloads.hpe.com/pub/softlib2/software1/pubsw-linux/p1093353304/v168967/ilorest_chif.so
  # But it seems this binary isn't compiled with `extern "C"`, so it's not very useful

  meta = with lib; {
    description = "Redfish library with additions for HPE iLO 4 and 5";
    license = licenses.asl20;
    homepage = "https://github.com/HewlettPackard/python-ilorest-library";
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.linux;
  };
}

