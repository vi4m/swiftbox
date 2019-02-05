#!/bin/sh

set -e
set -x

export PROJECT_PATH=/opt/swift_vapor_example
mkdir /root/artifact

$PROJECT_PATH/lddcopy.sh $PROJECT_PATH/.build/debug/swift_vapor_example $PROJECT_PATH/dist
cp $PROJECT_PATH/.build/debug/swift_vapor_example $PROJECT_PATH/dist

cp $PROJECT_PATH/project-properties.json $PROJECT_PATH/dist
cp -r $PROJECT_PATH/Config $PROJECT_PATH/dist/
cp -r $PROJECT_PATH/Resources $PROJECT_PATH/dist/
cp -r $PROJECT_PATH/Public $PROJECT_PATH/dist/

zip -r /root/artifact/swift_vapor_example.zip \
     $PROJECT_PATH/dist
