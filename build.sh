#!/bin/bash

RELEASE_DIR=release/
RELEASE_FILE=${RELEASE_DIR}/build_number.txt

mkdir -p $RELEASE_DIR
if [[ -f $RELEASE_FILE ]]; then
	build_number=$(cat ${RELEASE_FILE});
else
	build_number=0
fi
build_number=$((build_number+1))

echo $build_number > $RELEASE_FILE
mkdir -p ${RELEASE_DIR}/${build_number}
cp output_files/PSC_Trigger.sof ${RELEASE_DIR}/${build_number}/
cp output_files/PSC_Trigger.jic ${RELEASE_DIR}/${build_number}/

echo "SOF $(sha256sum ${RELEASE_DIR}/${build_number}/PSC_Trigger.sof)" >> ${RELEASE_DIR}/${build_number}/hashes.txt
echo "JIC $(sha256sum ${RELEASE_DIR}/${build_number}/PSC_Trigger.jic)" >> ${RELEASE_DIR}/${build_number}/hashes.txt

echo
echo Build ${build_number} released successfully.
