self: super: {

    gradle-4_10_3 = super.gradle-4_10_3.override {
        jdk = self.adoptopenjdk-hotspot-bin-14;
    };

    gradle-5_6_4 = super.gradle-5_6_4.override {
        jdk = self.adoptopenjdk-hotspot-bin-14;
    };

    gradle-6_2_2 = super.gradle-6_2_2.override {
        jdk = self.adoptopenjdk-hotspot-bin-14;
    };

    gradle-6_3 = super.gradle-6_3.override {
        jdk = self.adoptopenjdk-hotspot-bin-14;
    };

    gradle-6_4 = super.gradle-6_4.override {
        jdk = self.adoptopenjdk-hotspot-bin-14;
    };

    groovy-2_4_19 = super.groovy-2_4_19.override {
        jdk = self.adoptopenjdk-hotspot-bin-14;
    };

    groovy-2_5_10 = super.groovy-2_5_10.override {
        jdk = self.adoptopenjdk-hotspot-bin-14;
    };

    groovy-2_5_11 = super.groovy-2_5_11.override {
        jdk = self.adoptopenjdk-hotspot-bin-14;
    };

    groovy-3_0_2 = super.groovy-3_0_2.override {
        jdk = self.adoptopenjdk-hotspot-bin-11;
    };

    groovy-3_0_3 = super.groovy-3_0_3.override {
        jdk = self.adoptopenjdk-hotspot-bin-14;
    };

    micronaut-1_3_5 = super.micronaut-1_3_5.override {
        jdk = self.adoptopenjdk-hotspot-bin-14;
    };

    micronaut-1_3_4 = super.micronaut-1_3_4.override {
        jdk = self.adoptopenjdk-hotspot-bin-14;
    };

    spring-boot-cli-2_2_6 = super.spring-boot-cli-2_2_6.override {
        jdk = self.adoptopenjdk-hotspot-bin-14;
    };

    spring-boot-cli-2_2_7 = super.spring-boot-cli-2_2_7.override {
        jdk = self.adoptopenjdk-hotspot-bin-14;
    };
}