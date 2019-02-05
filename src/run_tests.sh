#!/bin/sh

# You should run a command that runs your tests and generate a file tests.xml
# with the results of your tests. This file is used to present the build results
# in Bamboo

# Generate example junit result file used in JUnit Parser plugin on Bamboo.

swift test

cat > tests.xml << EOL
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="nosetests" tests="1" errors="0" failures="0" skip="0">
<testcase classname="example.tests.functional.TestExample" name="test_should_return_view" time="0.465">
</testcase>
</testsuite>
EOL
