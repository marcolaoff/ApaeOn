buildscript {

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Google Services (Firebase)
        classpath("com.google.gms:google-services:4.4.1")

        // Android Gradle Plugin (AGP)
        classpath("com.android.tools.build:gradle:8.1.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Ajuste do diretório build (opcional)
val newBuildDir = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()

rootProject.layout.buildDirectory.set(newBuildDir)

// Aplica o buildDir customizado a todos os módulos
subprojects {

    val subprojectBuildDir = newBuildDir
        .dir(project.name)

    layout.buildDirectory.set(subprojectBuildDir)
}

// Tarefa clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
