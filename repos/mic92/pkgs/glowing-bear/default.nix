{ stdenv, fetchFromGitHub }: 

fetchFromGitHub {
  owner = "glowing-bear";
  repo = "glowing-bear";
  rev = "0.7.1";
  sha256 = "0gwrf67l3i3nl7zy1miljz6f3vv6zzc3g9as06by548f21cizzjb";

  meta = with stdenv.lib; {
    description = "A web client for WeeChat";
    homepage = "https://github.com/glowing-bear/glowing-bear";
    license = licenses.gpl3;
  };
}
