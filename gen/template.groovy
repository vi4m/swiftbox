import java.nio.charset.Charset
import java.nio.file.Files
import java.nio.file.Paths
import java.nio.file.StandardCopyOption

import static java.util.stream.Collectors.toList

String NAME = "swift_vapor_example"
File scriptDir = new File(getClass().protectionDomain.codeSource.location.path).parentFile
File projectDir = scriptDir.parentFile
// Hyphens are kind of problematic for Python, hence we need to convert them to
// underscores (see also comment for tycho.yaml below).
String appName = placeholders.projectName.replaceAll('-', '_')

def dirs = ["/docker", "/src" ]
for (dir in dirs) {
    Files.walk(new File(projectDir, dir).toPath())
            .filter { path -> !Files.isDirectory(path) }
            .filter { path -> !(path.toString().contains("Public")) }
            .forEach { file ->
        replace(file.toFile()) {
            filter { line -> line.replace(NAME, appName) }
            filter { line -> line.replace(NAME.toUpperCase(), appName.toUpperCase()) }
        }
    }
}

def filesWithEmail = ["docker/launch_docker_container.sh", "docker/Dockerfile-dev"]
for (fileWithEmail in filesWithEmail) {
    replace(projectDir, fileWithEmail) {
        filter { line -> filterLine(line, "pylabs@allegro.pl", placeholders.userEmail) }
    }
}

replace(projectDir, "tycho.yaml") {
    // Marathon does not accept underscores in apps names, hence we need to use
    // projectName here instead of appName, where the latter is normalized for Python
    // (i.e. hyphens converted to underscores).
    filter { line -> filterLine(line, "name: $NAME", "name: $placeholders.projectName") }
    filter { line -> filterLine(line, "pl.allegro.tech.appengine", placeholders.applicationGroup) }
}

def files = ["README.md", "build_bamboo_ci.sh", "tycho.yaml"]
for (file in files) {
    replace(projectDir, file) {
        filter { line -> filterLine(line, NAME, appName) }
        filter { line -> filterLine(line, NAME.toUpperCase(), appName.toUpperCase()) }
        filter { line -> filterLine(line, "pl.allegro.tech.appengine", placeholders.applicationGroup) }
    }
}

class Replacer {

    File file
    List<String> lines

    Replacer(File file) {
        println "setting file $file"
        this.file = file
        lines = Files.readAllLines(file.toPath(), Charset.forName('UTF-8'))
    }

    def filter(Closure mapper) {
        println("replacing")
        lines = lines.stream().map(mapper).collect(toList())
    }

    def save() {
        println "saving"
        Files.write(file.toPath(), lines, Charset.forName('UTF-8'))
    }
}

def replace(File file, Closure closure) {
    def replacer = new Replacer(file)
    closure.delegate = replacer
    closure()
    replacer.save()
}

def replace(File projectDir, String file, Closure closure) {
    replace(new File(projectDir, file), closure)
}

def move(String from, String to) {
    new File(to).mkdirs()
    Files.move(Paths.get(from), Paths.get(to), StandardCopyOption.REPLACE_EXISTING)
}

def filterLine(line, searchToken, replaceToken) {
    if (line.contains(searchToken)) {
        line = line.replace(searchToken, replaceToken)
    }
    line
}
