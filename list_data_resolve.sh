#! /bin/bash

# quietly pushd and popd
pushd () {
    command pushd "$@" > /dev/null
}
popd () {
    command popd "$@" > /dev/null
}

if [[ $# -eq 0 ]] ; then
    ac=NAC
else
    ac=$1
fi

pushd $SINGULARITY_HOME
for prj in CCIR_*
do
    pushd $prj
    for ses in ses-*
    do
	pushd $ses
	for tra in *_DT*-Converted-$ac
	do
	    pushd $tra
	    echo "\""$prj"\"" "\""$ses"\"" "\""$tra"\""
	    popd
	done
	popd
    done
    popd
done
popd
