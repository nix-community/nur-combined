self: super: {
    micronaut-1_3_4 = super.micronaut-1_3_4.override {
        jdk = self.adoptopenjdk-hotspot-bin-11;
    };
}