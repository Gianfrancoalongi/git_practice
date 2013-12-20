#!/bin/bash

DONE="Verified - you are done"
NOT_DONE="No - you are not done"

main() {
    scenario_1_tests
    scenario_2_tests
}

test_that_verification_fails_for_scenario() {
   if [[ $(bash ../scenario_${1}.bash --verify ${DIR}) == ${NOT_DONE} ]] 
    then
	echo "T${1}_neg passed"
    else 
	echo "T${1}_neg failed"
    fi
}

scenario_1_tests() {
    DIR=$(mktemp -d)
    test_that_verification_fails_for_scenario 1
    git init ${DIR} &> /dev/null
    if [[ $(bash ../scenario_1.bash --verify ${DIR}) == ${DONE} ]]
    then
	echo "T1_pos passed" 
    else 
	echo "T1_pos failed"
    fi
    rm -rf ${DIR} &> /dev/null
}

scenario_2_tests() {
    bash ../scenario_2.bash &> /dev/null
    DIR=$(cat repository.txt)
    test_that_verification_fails_for_scenario 2
    echo '*.txt' > ${DIR}/.gitignore
    if [[ $(bash ../scenario_2.bash --verify ${DIR}) == ${DONE} ]] 
    then
	echo "T2_pos passed" 
    else
	echo "T2_pos failed"
    fi
    rm -rf ${DIR} &> /dev/null
}

main

\rm *.txt
