self: super: {
  adoptopenjdk-bin = super.adoptopenjdk-hotspot-bin-16;
  adoptopenjdk-jre-bin = super.adoptopenjdk-jre-hotspot-bin-16;
  gradle = super.gradle-6_7_1;
  groovy = super.groovy-3_0_9;
  jbang = super.jbang-0_58_0;
  apache-maven = super.apache-maven-3_6_3;
  micronaut-cli = super.micronaut-cli-2_4_2;
  spring-boot-cli = super.spring-boot-cli-2_4_1;
}