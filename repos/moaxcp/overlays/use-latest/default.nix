self: super: {
  adoptopenjdk-bin = super.adoptopenjdk-hotspot-bin-16;
  adoptopenjdk-jre-bin = super.adoptopenjdk-jre-hotspot-bin-16;
  gradle = super.gradle-7_3_1;
  groovy = super.groovy-4_0_0;
  jbang = super.jbang-0_83_1;
  apache-maven = super.apache-maven-3_8_4;
  micronaut-cli = super.micronaut-cli-2_4_2;
  spring-boot-cli = super.spring-boot-cli-2_4_1;
}