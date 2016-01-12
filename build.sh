#!/bin/bash

CWD=$(pwd)
VERSION=2.1.2
SPEC="runit.spec"
SOURCE_URL="http://smarden.org/runit/runit-${VERSION}.tar.gz"

which wget > /dev/null
if [ $? -ne 0 ]; then
  echo "Aborting. Cannot continue without wget."
  exit 1
fi

which rpmbuild > /dev/null
if [ $? -ne 0 ]; then
  echo "Aborting. Cannot continue without rpmbuild from the rpm-build package."
  exit 1
fi

echo "Creating RPM build path structure..."
mkdir -p rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS,tmp}

cp ${SPEC} rpmbuild/SPECS/
cp *.patch rpmbuild/SOURCES/
cp *.service rpmbuild/SOURCES/

echo "Downloading sources..."
cd rpmbuild/SOURCES
if [ ! -f runit-${VERSION}.tar.gz ]; then
  wget ${SOURCE_URL}
fi

if [ -f ${CWD}/gpg-env ]; then
  echo "Building RPM with GPG signing..."
  cd ${CWD}

  source gpg-env
  if [ "${gpg_bin}" != "" ]; then
    rpmbuild --define "_topdir ${CWD}/rpmbuild" \
      --define "_signature ${signature}" \
      --define "_gpg_path ${gpg_path}" --define "_gpg_name ${gpg_name}" \
      --define "__gpg ${gpg_bin}" --sign -ba ${SPEC}
  else
    rpmbuild --define "_topdir ${CWD}/rpmbuild" \
      --define "_signature ${signature}" \
      --define "_gpg_path ${gpg_path}" --define "_gpg_name ${gpg_name}" \
      --sign --ba ${SPEC}
  fi
else
  echo "Building RPM..."
  cd ${CWD}
  rpmbuild --define "_topdir ${CWD}/rpmbuild" --ba ${SPEC}
fi

