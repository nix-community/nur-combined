# TODO wait for https://nixpk.gs/pr-tracker.html?pr=166335
let
  overrider = final': prev': {
    pycurl = prev'.pycurl.overrideAttrs (old: {
      disabledTests = (old.disabledTests or [ ]) ++ [
        "test_getinfo_raw_certinfo"
        "test_request_with_certinfo"
        "test_request_with_verifypeer"
        "test_request_without_certinfo"
      ];
    });
  };
in
final: prev: {
  python3Packages = prev.python3Packages.overrideScope overrider;
}
