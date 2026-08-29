{
  ghostty-bin,
  stdenvNoCC,
  ghostty,
  ...
}:
if stdenvNoCC.hostPlatform.isDarwin
then ghostty-bin
else ghostty
