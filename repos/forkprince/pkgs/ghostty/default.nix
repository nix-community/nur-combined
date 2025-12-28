{
  ghostty-bin,
  stdenvNoCC,
  ghostty,
  ...
}:
if stdenvNoCC.isDarwin
then ghostty-bin
else ghostty
