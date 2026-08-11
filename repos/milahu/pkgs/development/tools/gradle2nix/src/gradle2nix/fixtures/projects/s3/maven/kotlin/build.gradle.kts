plugins {
    java
}

repositories {
    maven {
        url = uri("s3://repositories/m2")
        credentials(AwsCredentials::class) {
            accessKey = "foo"
            secretKey = "bar"
        }
    }
}

dependencies {
    implementation("org.apache:test:1.0.0")
}
