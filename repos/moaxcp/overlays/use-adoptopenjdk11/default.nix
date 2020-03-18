self: super: {
    nur.repos.moaxcp.micronaut-1_3_3 = super.nur.repos.moaxcp.micronaut-1_3_3.override {
        jdk = self.adoptopenjdk-hotspot-bin-11;
    };
}