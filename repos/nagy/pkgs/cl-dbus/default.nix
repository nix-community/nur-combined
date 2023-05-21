{ lispPackages_new, fetchFromGitHub, ... }:

lispPackages_new.sbclPackages.dbus.overrideLispAttrs (_old: {
  src = fetchFromGitHub {
    owner = "nagy";
    repo = "dbus";
    rev = "8dfecd6e5b6ccb0907a03076a0ab5def6b48fbda";
    sha256 = "0lpj40b9pgqq8cp3qmyi7zlcm90fxf8wh0c21cbyy42j4b98z6f5";
  };
})
