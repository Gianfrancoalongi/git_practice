#!/bin/bash

DONE="Verified - you are done"
NOT_DONE="No - you are not done"

main() {
    scenario_1_tests
    scenario_2_tests
    scenario_3_tests
    scenario_4_tests
}

scenario_1_tests() {
    DIR=$(mktemp -d)
    test_that_verification_fails_for_scenario 1 ${DIR}
    git init ${DIR} &> /dev/null
    test_that_verification_passes_for_scenario 1 ${DIR}
    rm -rf ${DIR} &> /dev/null
}

scenario_2_tests() {
    bash ../scenario_2.bash &> /dev/null
    DIR=$(cat repository.txt)
    test_that_verification_fails_for_scenario 2 ${DIR}
    echo '*.txt' > ${DIR}/.gitignore
    test_that_verification_passes_for_scenario 2 ${DIR}
    rm -rf ${DIR} &> /dev/null
}

scenario_3_tests() {
    bash ../scenario_3.bash &> /dev/null
    DIR=$(cat repository.txt)
    test_that_verification_fails_for_scenario 3 ${DIR}
    pushd ${DIR} &> /dev/null
    git config --local core.editor 'emacs -nw'
    git config --local merge.tool kdiff3
    popd &> /dev/null
    test_that_verification_passes_for_scenario 3 ${DIR}
    rm -rf ${DIR} &> /dev/null
}

scenario_4_tests() {
    bash ../scenario_4.bash &> /dev/null
    DIR=$(cat repository.txt)
    test_that_verification_fails_for_scenario 4 ${DIR}
    pushd ${DIR} &> /dev/null
    echo 'I made this.' >> file.txt
    git add file.txt
    git commit -m "Added the file as requested."
    popd &> /dev/null
    test_that_verification_passes_for_scenario 4 ${DIR}
    rm -rf ${DIR} &> /dev/null
}


test_that_verification_fails_for_scenario() {
    if [[ $(bash ../scenario_${1}.bash --verify ${2}) == ${NOT_DONE} ]] 
    then
    	echo "T${1}_neg passed"
    else 
    	echo "T${1}_neg failed"
    fi
}

test_that_verification_passes_for_scenario() {
    if [[ $(bash ../scenario_${1}.bash --verify ${2}) == ${DONE} ]]
    then
	echo "T${1}_pos passed" 
    else 
	echo "T${1}_pos failed"
    fi
}

main

\rm *.txt
