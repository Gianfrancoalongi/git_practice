#!/bin/bash

DONE="Verified - you are done"
NOT_DONE="No - you are not done"

main() {
   scenario_1_tests

   for((x=2;x<8;x++))
   do
       bash ../scenario_${x}.bash &> /dev/null
       DIR=$(cat repository.txt)
       test_that_verification_fails_for_scenario ${x} ${DIR}
       pushd ${DIR} &> /dev/null
       solution_for_scenario_${x} ${DIR}
       popd &> /dev/null
       test_that_verification_passes_for_scenario ${x} ${DIR}
       rm -rf ${DIR} &> /dev/null
   done
}

scenario_1_tests() {
    DIR=$(mktemp -d)
    test_that_verification_fails_for_scenario 1 ${DIR}
    git init ${DIR} &> /dev/null
    test_that_verification_passes_for_scenario 1 ${DIR}
    rm -rf ${DIR} &> /dev/null
}

solution_for_scenario_2() {
    echo '*.txt' > ${1}/.gitignore
}

solution_for_scenario_3() {
    git config --local core.editor 'emacs -nw'
    git config --local merge.tool kdiff3
}

solution_for_scenario_4() {
    echo 'I made this.' >> file.txt
    git add file.txt &> /dev/null
    git commit -m "Added the file as requested." &> /dev/null
}

solution_for_scenario_5() {
    git reset HEAD b.txt &> /dev/null
}

solution_for_scenario_6() {
    git commit --amend -m 'Correct commit message.' &> /dev/null
}

solution_for_scenario_7() {
    git checkout a.txt
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
