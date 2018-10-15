{ fetchFromGitHub }:

{
  version = "2018-10-15";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "4a47d349a130f243220f6f2ec8fbef27434eb324";
    sha256 = "06shiz5iaa6r14s6jkzav9pav6zz416f3czb0s023bhva4gvr688";
    name = "mcsema-source";
  };
}
