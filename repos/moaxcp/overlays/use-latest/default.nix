self: super: {
  adoptopenjdk-bin = super.adoptopenjdk-hotspot-bin-15;
  adoptopenjdk-jre-bin = super.adoptopenjdk-jre-hotspot-bin-15;
  gradle = super.gradle-6_7_1;
  groovy = super.groovy-3_0_7;
  micronaut-cli = super.micronaut-cli-2_2_2;
  spring-boot-cli = super.spring-boot-cli-2_4_1;
}