self: super: {
    micronaut-1_3_3 = super.micronaut-1_3_3.override {
        jdk = self.adoptopenjdk-hotspot-bin-11;
    };
}