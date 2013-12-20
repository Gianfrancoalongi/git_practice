#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_if_files_are_properly_ignored_at $2
    else
	setup_scenario
	generate_description_file
	generate_help_file
	show_scenario_text
    fi
}

show_scenario_text() {
    cat <<EOF
*****************************************************************
Scenario set up.
You can always read 
    description.txt to know what you need to do
    help.txt to get pointers on what to read in order to succeed
    repository.txt  to see where the scenario is created
*****************************************************************
Run this script as
       $0 --verify ${SCENARIO_GIT_REPO}
when you think you are done
*****************************************************************
EOF
echo "> description.txt"
cat description.txt
echo "*****************************************************************"
echo "> help.txt"
cat help.txt
echo "*****************************************************************"
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d)
    pushd ${SCENARIO_GIT_REPO} &> /dev/null
    for i in {1..100}; do touch ${i}.txt; done
    git init . &> /dev/null
    popd &> /dev/null
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Make sure that all *.txt files are properly ignored in the git repo 
which can be found in 
    ${SCENARIO_GIT_REPO}
when issuing the command
    git status

You can find the repository location in the file named 
    repository.txt
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 2.2 Git Basisc - Recording Changes to the Repository
 subchapter Ignoring Files.
EOF
}

check_if_files_are_properly_ignored_at() {
    pushd $1 &> /dev/null
    if [[ ($(find . -name \*.txt | wc -l) == 100)  ]]
    then
	if [[ $(git status | grep -A 100 "Untracked files:" | tail +4 | wc -l) == 2 ]]
	then
	    RES="Verified - you are done"
	else
	    RES="No - you are not done"
	fi
    fi
    echo ${RES}
    popd &> /dev/null
}

main $@
