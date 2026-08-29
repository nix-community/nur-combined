{
  stdenvNoCC,
  micro-full,
  micro,
  ...
}:
if stdenvNoCC.hostPlatform.isDarwin
then micro
else micro-full
