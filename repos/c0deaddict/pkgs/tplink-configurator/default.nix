{ writeScriptBin, openjdk11, ... }:

# Created from 'Easy Smart Configuration Utility v1.1.1.0.zip'
# sha256: cea3280a1c679b020c62d5ea4bcc652b422eb2b801a6082ed49a287a37d988e5

# TODO: temporarily add this rule: (and replace the IP address in there)
# sudo iptables -t nat -A PREROUTING -p udp -d 255.255.255.255 --dport 29809 -j DNAT --to 10.13.37.104:29809
writeScriptBin "tplink-configurator" ''
  ${openjdk11}/bin/java -jar ${./tplink-configurator-v1.1.1.0.jar}
''
