#!/bin/bash

DONE="Verified - you are done"
NOT_DONE="No - you are not done"

main() {
    scenario_1_tests
    scenario_2_tests
}

scenario_1_tests() {
    DIR=$(mktemp -d)
    test_that_verification_fails_for_scenario 1
    git init ${DIR} &> /dev/null
    test_that_verification_passes_for_scenario 1
    rm -rf ${DIR} &> /dev/null
}

scenario_2_tests() {
    bash ../scenario_2.bash &> /dev/null
    DIR=$(cat repository.txt)
    test_that_verification_fails_for_scenario 2
    echo '*.txt' > ${DIR}/.gitignore
    test_that_verification_passes_for_scenario 2
    rm -rf ${DIR} &> /dev/null
}

test_that_verification_fails_for_scenario() {
   if [[ $(bash ../scenario_${1}.bash --verify ${DIR}) == ${NOT_DONE} ]] 
    then
	echo "T${1}_neg passed"
    else 
	echo "T${1}_neg failed"
    fi
}

test_that_verification_passes_for_scenario() {
    if [[ $(bash ../scenario_${1}.bash --verify ${DIR}) == ${DONE} ]]
    then
	echo "T${1}_pos passed" 
    else 
	echo "T${1}_pos failed"
    fi
}

main

\rm *.txt
