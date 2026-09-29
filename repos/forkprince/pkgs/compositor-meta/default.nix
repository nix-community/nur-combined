{
  stdenvNoCC,
  compositor,
  xuan,
}:
if stdenvNoCC.hostPlatform.isDarwin
then compositor
else xuan
