#!/bin/bash

DONE="Verified - you are done"
NOT_DONE="No - you are not done"

main() {
    scenario_1_tests
    scenario_2_tests
}

scenario_1_tests() {
    DIR=$(mktemp -d)
    if [[ $(bash ../scenario_1.bash --verify ${DIR}) == ${NOT_DONE} ]] 
    then
	echo "T1_neg passed"
    else 
	echo "T1_neg failed"
    fi
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
    if [[ $(bash ../scenario_2.bash --verify ${DIR}) == ${NOT_DONE} ]] 
    then
	echo "T2_neg passed" 
    else
	echo "T2_neg failed"
    fi
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
