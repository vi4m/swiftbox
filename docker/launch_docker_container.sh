#!/bin/bash

set -x
set -e

# This script is used to run your applications on Mesos.

./swift_vapor_example --env=$@
