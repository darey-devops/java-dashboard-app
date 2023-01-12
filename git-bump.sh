#!/bin/bash

git fetch --tags
current_version=$(git describe --tags --abbrev=0)
echo "Current Version = $current_version"
# Get the current version numbers
major=$(echo $current_version | awk -F '.' '{print $1}')
minor=$(echo $current_version | awk -F '.' '{print $2}')
patch=$(echo $current_version | awk -F '.' '{print $3}')
# Set release type
release_type="patch"
echo "Release type = $release_type"
# Bump the version based on the release type
if [ "$release_type" == "major" ]; then
    major=`expr $major + 1`
    minor=0
    patch=0
elif [ "$release_type" == "minor" ]; then
    minor=`expr $minor + 1`
    patch=0
elif [ "$release_type" == "patch" ]; then
    patch=`expr $patch + 1`
else
    echo "Invalid release type"
    exit 1
fi
# Create the new version string
echo "New Version new_version"
new_version="$major.$minor.$patch"

# Create a new tag for the new version
git tag -a "$new_version" -m "Release $new_version"

# Push the new tag to the remote repository
git push --tags