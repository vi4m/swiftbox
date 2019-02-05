#!/bin/bash
set -e

# This script generate version from git tags (only from annotated tags)
# Example of the output of the script:
#
#   $ git tag -a 0.1.0 -m "0.1.0"
#
#   $ bash get_version.sh
#   0.1.0
#
#   $ echo "Lorem ipsum" > example_file
#   $ git add example_file
#   $ git commit -m "Add file"
#   [master de9d514] feature commit
#    1 file changed, 1 insertion(+), 1 deletion(-)
#
#   $ bash get_version.sh
#   0.1.1-SNAPSHOT
#
#   $ git checkout -b feature/APPCONSOLE-123
#   Switched to a new branch 'feature/APPCONSOLE-123'
#
#   $ bash get_version.sh
#   0.1.1-feature-APPCONSOLE-123-SNAPSHOT
#
#   $ git checkout master
#   Switched to branch 'master'
#
#   $ git tag -a 0.1.1 -m "0.1.1"
#   $ bash ~/workspace/version-bash/get_version.sh
#   0.1.1

# set first tag when any does not exist
set +e
git describe --tags > /dev/null 2>&1
EXIT_CODE=$?
set -e
if [ $EXIT_CODE != 0 ]
then
    git tag -a 0.1.0 -m "0.1.0"
fi


current_branch=`git rev-parse --abbrev-ref HEAD`

die(){
    echo "$1"
    exit 2
}

show_version(){
    echo "$1"
    exit 0
}

# bump PATH number of version complies with semantic versioning
# version format MAJOR.MINOR.PATCH - http://semver.org/
generate_next_version(){
    major_and_minor=`echo "$1" | cut -d '.' -f1-2`
    path_number=`echo "$1" | cut -d '.' -f3`
    incremented_patch=$((path_number+1))
    next_version="${major_and_minor}.${incremented_patch}"
}


if [ -z "$current_branch" ]; then
    die "Empty commits list on this branch or you didn't commit anything"
fi

current_tag=`git describe`

if [ -z "$current_tag" ]; then
    die "you don't have any tag on branch : ${current_branch}"
fi

# check if any of commit has been added after last tag
changes_above_tag=`echo $current_tag | sed '/^.*-[0-9]-[a-z0-9].*/p' | wc -l | xargs`

clean_tag=`git describe --abbrev=0`


if [ "$current_branch" == "master" ]; then
    if [ "$changes_above_tag" == 1 ]; then
        version="${clean_tag}"
    else
        generate_next_version "$clean_tag"
        bumped_clean_tag="$next_version"
        version="${bumped_clean_tag}-SNAPSHOT"
    fi
else
    generate_next_version "$clean_tag"
    bumped_clean_tag="$next_version"
    # Sanitize version - all characters that do not match [A-Za-z0-9._-]
    # group are replaced with `-`
    sanitized_branch_name=`echo $current_branch | sed 's/[^a-zA-Z0-9]/-/g'`
    version="${bumped_clean_tag}-${sanitized_branch_name}-SNAPSHOT"
fi
show_version "$version"
