{
  fortune,
  stdenv,
  fetchFromGitHub,
  lib,
  jq,
  ...
}:
stdenv.mkDerivation rec {
  version = "1.0.431";
  pname = "fortune-mod-hitokoto";
  src = fetchFromGitHub {
    owner = "hitokoto-osc";
    repo = "sentences-bundle";
    rev = "v${version}";
    hash = "sha256-aGh3j3pZRRjwvh70MDxY6/aTTi4nowHfEjK4RtmSn/U=";
  };
  nativeBuildInputs = [
    fortune
    jq
  ];
  buildPhase = ''
    runHook preBuild

    NO_FORMAT="\033[0m"
    C_YELLOW1="\033[38;5;226m"
    C_VIOLET="\033[38;5;177m"
    mkdir -p output
    cat "$(cat ./version.json | jq -r  ".categories.path")" | jq -c '.[] | {name: .name, path: .path}' | while read -r line; do
      __name=$(echo $line | jq -r '.name')
      __path=$(echo $line | jq -r '.path')
      echo "Processing category: $__name, path: $__path"
      cat "$__path" | jq -c '.[]' | while read -r sentence; do
        __hitokoto=$(echo "$sentence" | jq -r '.hitokoto')
        __from=$(echo "$sentence" | jq -r '.from')
        __formatted="''${C_YELLOW1}''${__from}''${NO_FORMAT}: “''${C_VIOLET}''${__hitokoto}''${NO_FORMAT}”\n"
        echo -e "$__formatted%" >> output/$__name
      done
      strfile -c % output/$__name output/$__name.dat
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fortune/hitokoto
    cp -r output/* $out/share/fortune/hitokoto/

    runHook postInstall
  '';

  meta = with lib; {
    description = ''一言开源社区官方提供的语句库，系 `hitokoto.cn` 数据打包集合。语句接口默认使用此库。(fortune 适配版本)'';
    homepage = "https://github.com/hitokoto-osc/sentences-bundle";
    platforms = fortune.meta.platforms;
    license = with licenses; [agpl3Only];
    sourceProvenance = with sourceTypes; [fromSource];
  };
}
