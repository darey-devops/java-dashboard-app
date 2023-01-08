#!/bin/bash
# set -xe 
PROJECT_FILE_CONTENTS=$(cat PROJECT_FILE)
echo ${PROJECT_FILE_CONTENTS}
CURRENT_VERSION=$(echo $PROJECT_FILE_CONTENTS | awk '/^version/ {print $3}')

# Check if the current version is a release version (e.g. 1.2.3) or a prerelease version (e.g. 1.2.3-beta.1)
# if [[ $CURRENT_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
#   # If the current version is a release version, bump the patch version (e.g. 1.2.3 -> 1.2.4)
#   NEW_VERSION=$(awk -F. -v CURRENT_VERSION="$CURRENT_VERSION" '{print $1, $2, $3+1}' <<< "$CURRENT_VERSION")
# else
#   # If the current version is a prerelease version, bump the prerelease version (e.g. 1.2.3-beta.1 -> 1.2.3-beta.2)
#   NEW_VERSION=$(echo $CURRENT_VERSION | awk -F '{printf "%d.%d.%d\n", $1,$2,$3+1}')
# fi

echo "Current Version: ${CURRENT_VERSION}"
NEW_VERSION=$(awk -F. -v CURRENT_VERSION="$CURRENT_VERSION" '{print $1, $2, $3+1}' <<< "$CURRENT_VERSION")
echo "New Version" ${NEW_VERSION}

CURRENT_VERSION="1.2.3-beta.1"
semvar=$(awk -F- -v version="$version" '{print $1}' <<< "$version")
pre_release=$(awk -F- -v version="$version" '{print $2}' <<< "$version")
echo "PRE_RELEASE: $pre_release"
NEW_PRE_RELEASE=$(awk -F. -v pre_release="$pre_release" '{print $1,  $2+1}' <<< "$pre_release")
# put an if condition here to check if its "beta" or "alpha"
CONCATENATED_NEW_VERSION="$semvar-$NEW_PRE_RELEASE"
# if alpha is found, use the below
# Alpha: Alpha releases are the first versions of a software product that are made available to a small group of testers. Alpha releases are typically unstable and contain many bugs, as they are still under development.
NEW_VERSION=$(echo $CONCATENATED_NEW_VERSION | sed 's/alpha /alpha./')

# if beta is found, use the below
# Beta: Beta releases are the next stage of development after alpha releases. Beta releases are made available to a larger group of testers and are generally more stable than alpha releases. However, beta releases may still contain bugs and other issues that need to be addressed before the final release.
NEW_VERSION=$(echo $CONCATENATED_NEW_VERSION | sed 's/beta /beta./')

echo "New beta version: ${NEW_VERSION}"


# The regular expression ^[0-9]+\.[0-9]+\.[0-9]+$ is used to match a semantic version string in the form X.Y.Z, where X, Y, and Z are integers.

# The ^ character is an anchor that matches the start of the string. The [0-9]+ character class matches one or more digits, and the \. character matches a literal period. This pattern is repeated three times, separated by literal periods, to match three sets of digits separated by periods. The $ character is another anchor that matches the end of the string.

# Together, these characters match a string that consists of three sets of digits separated by periods, with no other characters present. This pattern is used to determine whether the current version is a release version (e.g. 1.2.3) or a prerelease version (e.g. 1.2.3-beta.1).

# If the current version matches the regular expression, it is considered a release version and the patch version (the Z component) is incremented by one. If the current version does not match the regular expression, it is considered a prerelease version and the prerelease version is incremented by one.

# Update the version in the project's metadata
# Replace PROJECT_FILE and VERSION_VARIABLE with the path to the project file and the name of the variable that stores the version, respectively
# version="1.2.3"
# sed -i "s/\bversion=.*/version=${NEW_VERSION}/g" /tmp/PROJECT_FILE

# The sed command is a utility that allows you to perform search and replace operations on text files. The -i flag specifies that the file should be edited in place, rather than writing the output to a new file.

# The s/old/new/g syntax is used to replace all occurrences of the old pattern with the new pattern. In this case, the old pattern is \b${VERSION_VARIABLE}\b=\b[^ ]*\b, which matches the VERSION_VARIABLE variable followed by an equal sign and zero or more characters other than a space. The new pattern is VERSION_VARIABLE=${NEW_VERSION}, which replaces the matched old pattern with the NEW_VERSION variable.

# The \b characters are word boundaries, which match the position between a word character (as defined by the \w character class) and a non-word character. The [^ ]* character class matches zero or more characters other than a space. The g flag at the end of the expression specifies that the sed command should perform the replacement globally, replacing all occurrences of the old pattern in the file.

# In this case, the sed command is used to update the VERSION_VARIABLE variable in the PROJECT_FILE with the NEW_VERSION variable. This allows you to update the version of the project in the project's metadata.



# Commit the version bump and push to the remote repository
git commit -am "Bump version to $NEW_VERSION"
git push https://github.com/darey-devops/java-dashboard-app.git
