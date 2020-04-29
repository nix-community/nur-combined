self: super: {
    micronaut-1_3_4 = super.micronaut-1_3_4.override {
        jdk = self.adoptopenjdk-hotspot-bin-11;
    };

    gradle-6_3 = super.gradle-6_3.override {
        jdk = self.adoptopenjdk-hotspot-bin-11;
    };
}