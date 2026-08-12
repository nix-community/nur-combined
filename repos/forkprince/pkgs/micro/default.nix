{
  stdenvNoCC,
  micro-full,
  micro,
  ...
}:
if stdenvNoCC.isDarwin
then micro
else micro-full
