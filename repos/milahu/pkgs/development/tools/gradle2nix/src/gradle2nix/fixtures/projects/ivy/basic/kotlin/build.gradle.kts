plugins {
    java
}

repositories {
    ivy {
        url = uri("https://asset.opendof.org")
        patternLayout {
            ivy("ivy2/[organisation]/[module]/[revision]/ivy(.[platform]).xml")
            artifact("artifact/[organisation]/[module]/[revision](/[platform])(/[type]s)/[artifact]-[revision](-[classifier]).[ext]")
        }
    }
}

dependencies {
    dependencies {
        implementation("org.opendof.core-java:dof-cipher-sms4:1.0")
    }
}
