{ autoreconfHook, fetchFromGitHub, lib, stdenv }:
stdenv.mkDerivation rec {
  name = "cpuid2cpuflags-${version}";
  version = "v12";
  src = fetchFromGitHub {
    owner = "projg2";
    repo = "cpuid2cpuflags";
    rev = version;
    sha256 = "sha256-z9MPlE1egT0CqvClcbAXvcCvyAueWNs5AJ8mXnOawg8=";
  };

  nativeBuildInputs = [ autoreconfHook ];
  doCheck = true;

  meta = with lib; {
    description = "CPU_FLAGS_* generator";
    longDescription = ''
      Obtains the identification and capabilities of the currently used CPU,
      and print the matching set of CPU_FLAGS_* flags for Gentoo.
    '';
    homepage = "https://github.com/projg2/cpuid2cpuflags";
    changelog =
      "https://github.com/projg2/cpuid2cpuflags/releases/tag/${version}";
    license = licenses.bsd2;
  };
}
