//allprojects {
//    repositories {
//        google()
//        mavenCentral()
//    }
//}

allprojects {
    repositories {
        google()

        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
        maven {
            url = uri("https://developer.huawei.com/repo/")
        }

        maven {
            url = uri("https://artifactory.aigroup.uz/artifactory/myid")
        }

        mavenCentral()
    }
}
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")

//    afterEvaluate { project ->
//        if (project.hasProperty("android")) {
//            // MyID SDK modullari uchun alohida namespace majburlash
//            if (project.name.contains("myid-integrity-sdk")) {
//                project.android.namespace = "uz.myid.android.sdk.integrity"
//            } else if (project.name.contains("myid-video-capture-sdk")) {
//                project.android.namespace = "uz.myid.android.sdk.video"
//            }
//        }
//    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
