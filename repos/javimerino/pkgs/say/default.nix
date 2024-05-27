{ lib
, fetchFromGitHub
, piper-tts
, sox
, writeShellApplication
}:


let
  say_repo = fetchFromGitHub {
    owner = "JaviMerino";
    repo = "say-tts";
    rev = "0ebb75cdf2c299319c56d143dd3698704941ea71";
    hash = "sha256-36D3gRg9j7UKGLcUr7vZ13F7N1pE9CLOS8kMPSqeJ9o=";
  };
  say_text = builtins.readFile "${say_repo}/say";
in
writeShellApplication {
  name = "say";

  text = say_text;
  runtimeInputs = [
    piper-tts
    sox
  ];

  meta = with lib; {
    broken = true;
    description = "Simple CLI for converting text to speech using piper-tts";
    homepage = "https://github.com/JaviMerino/mail_replyer";
    maintainers = with maintainers; [ javimerino ];
    license = licenses.mit;
  };
}
