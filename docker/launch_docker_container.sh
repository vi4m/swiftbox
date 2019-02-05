#!/bin/bash

set -x
set -e

# This script is used to run your applications on Mesos.

./swiftbox --env=$@
