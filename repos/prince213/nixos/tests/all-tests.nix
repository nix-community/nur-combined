{ runTest }:
{
  hydro = runTest ./hydro.nix;
  hydro-standalone-judge = runTest ./hydro-standalone-judge.nix;
}
