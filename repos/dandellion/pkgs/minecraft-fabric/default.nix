{ callPackage, writeTextFile, writeShellScriptBin, minecraft-server, jre_headless }:

let
  loader = callPackage ./generate-loader.nix {};
  log4j = writeTextFile {
    name = "log4j.xml";
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <Configuration status="WARN" packages="com.mojang.util">
          <Appenders>
              <Console name="SysOut" target="SYSTEM_OUT">
                  <PatternLayout pattern="[%d{HH:mm:ss}] [%t/%level]: %msg%n" />
              </Console>
              <Queue name="ServerGuiConsole">
                  <PatternLayout pattern="[%d{HH:mm:ss} %level]: %msg%n" />
              </Queue>
              <RollingRandomAccessFile name="File" fileName="logs/latest.log" filePattern="logs/%d{yyyy-MM-dd}-%i.log.gz">
                  <PatternLayout pattern="[%d{HH:mm:ss}] [%t/%level]: %msg%n" />
                  <Policies>
                      <TimeBasedTriggeringPolicy />
                      <OnStartupTriggeringPolicy />
                  </Policies>
                  <DefaultRolloverStrategy max="1000"/>
              </RollingRandomAccessFile>
          </Appenders>
          <Loggers>
              <Root level="debug">
                  <AppenderRef ref="SysOut"/>
                  <AppenderRef ref="File"/>
                  <AppenderRef ref="ServerGuiConsole"/>
              </Root>
          </Loggers>
      </Configuration>
    '';
  };
in
writeShellScriptBin "minecraft-server" ''
  echo "serverJar=${minecraft-server}/lib/minecraft/server.jar" >> fabric-server-launcher.properties
  exec ${jre_headless}/bin/java -Dlog4j.configurationFile=${log4j} $@ -jar ${loader} nogui
''
