DESCRIBE_REGEX='^(.+)-(.+)-g(.+)$'
SEMVER_REGEX='^v([1-9]\d*|0).([1-9]\d*|0).([1-9]\d*|0)$'
IS_DEV_VERSION="true"

DESCRIBE_RES=`git describe --long --abbrev=8 --match 'v[0-9]*.[0-9]*.[0-9]*' 2> /dev/null`
if [ $? != 0 ] ; then
  COMMIT_DISTANCE=`git rev-list --count HEAD`
  COMMIT_HASH=`git log -n1 --format=%h`
  VERSION="0.1.0"
elif [[ "${DESCRIBE_RES}" =~ ${DESCRIBE_REGEX} ]] ; then
  TAG=${BASH_REMATCH[1]}
  COMMIT_DISTANCE=${BASH_REMATCH[2]}
  COMMIT_HASH=${BASH_REMATCH[3]}

  if [[ "$TAG" =~ $SEMVER_REGEX ]] ; then
    MAJOR=${BASH_REMATCH[1]}
    MINOR=${BASH_REMATCH[2]}
    PATCH=${BASH_REMATCH[3]}
    VERSION="${MAJOR}.${MINOR}.${PATCH}"

    if [ ${COMMIT_DISTANCE} == 0 ] ; then
      IS_DEV_VERSION="false"
    fi
  else
    VERSION="${TAG}"
  fi
else
  echo "::error ::Git describe returned an invalid description"
  exit 1
fi

if [ $IS_DEV_VERSION == 'true' ] ; then
  PRERELEASE="dev.${COMMIT_DISTANCE}"
  BUILD="${COMMIT_HASH}"
  VERSION="${VERSION}-${PRERELEASE}+${BUILD}"
fi

echo "::set-output name=major::${MAJOR}"
echo "::set-output name=minor::${MINOR}"
echo "::set-output name=patch::${PATCH}"
echo "::set-output name=prerelease::${PRERELEASE}"
echo "::set-output name=build::${BUILD}"
echo "::set-output name=version::${VERSION}"
echo "::set-output name=is-dev-version::${IS_DEV_VERSION}"