
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
    implementation("org.apache:test-SNAPSHOT1:2.0.0-SNAPSHOT")
}
