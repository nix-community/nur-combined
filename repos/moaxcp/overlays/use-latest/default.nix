self: super: {
  adoptopenjdk-bin = self.adoptopenjdk-hotspot-bin-15;
  adoptopenjdk-jre-bin = self.adoptopenjdk-jre-hotspot-bin-15;
  gradle = self.gradle-6_7_1;
  groovy = self.groovy-3_0_7;
  micronaut-cli = self.micronaut-cli-2_2_2;
  spring-boot-cli = self.spring-boot-cli-2_4_1;
}