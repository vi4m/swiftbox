#!/usr/bin/env groovy
@Grapes([
        @Grab(group = 'org.apache.commons', module = 'commons-lang3', version = '3.4'),
        @Grab(group = 'commons-io', module = 'commons-io', version = '2.4')
])

import org.apache.commons.io.FileUtils
import org.apache.commons.lang3.RandomStringUtils

File scriptDir = new File(getClass().protectionDomain.codeSource.location.path).parentFile
File projectDir = scriptDir.parentFile

File testsDir = new File(projectDir.path, "/build/tests")
FileUtils.deleteDirectory(testsDir)
testsDir.mkdirs()

def testAppName = "seller-dictionary"
File testAppDir = new File(testsDir, testAppName)

copyDirectory(new File(projectDir, 'docker'), new File(testAppDir, 'docker'))
copyDirectory(new File(projectDir, 'gen'), new File(testAppDir, 'gen'))
copyDirectory(new File(projectDir, 'src'), new File(testAppDir, 'src'))

copyFile(new File(projectDir, 'README.md'), new File(testAppDir, 'README.md'))
copyFile(new File(projectDir, 'build_bamboo_ci.sh'), new File(testAppDir, 'build_bamboo_ci.sh'))
copyFile(new File(projectDir, 'docker/package_artifact.sh'), new File(testAppDir, 'docker/package_artifact.sh'))
copyFile(new File(projectDir, 'tycho.yaml'), new File(testAppDir, 'tycho.yaml'))

def placeholders = [
        projectName: testAppName,
        applicationGroup: 'pl.allegro.tech.workshop',
        userEmail: 'test@test',
        domain: 'tech',
        context: 'workshop',
        fullUserName: 'John Doe',
        bambooKey: 'PRO-PLANCI',
        fullApplicationName: "pl.allegro.tech.workshop.$testAppName",
]

Binding binding = new Binding();
binding.setVariable('placeholders', placeholders);
GroovyShell shell = new GroovyShell(binding);
shell.evaluate(new File(testAppDir, 'gen/template.groovy'));

println "Finished."

def copyDirectory(File from, File to) {
    to.mkdirs()
    FileUtils.copyDirectory(from, to)
}

def copyFile(File from, File to) {
    FileUtils.copyFile(from, to)
    to.setExecutable(from.canExecute())
}
