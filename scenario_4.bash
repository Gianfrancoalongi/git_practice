#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_file_is_properly_committed $2
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
    git init . &> /dev/null
    popd &> /dev/null
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Add a file called file.txt containing the text

    I made this!

to the git repository, commit it with the commit message

    Added the file as requested.

You can find the repository location in the file named 
    repository.txt
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 2.2 Git Basics - Recording Changes to the Repository
EOF
}


check_that_file_is_properly_committed() {
    pushd $1 &> /dev/null
    FILE=$(git log --name-only --pretty=oneline 2>/dev/null | tail -n 1)
    MSG=$(git log --name-only --pretty=oneline 2>/dev/null | head -n 1 | cut -d ' ' -f 2-)
    if [[ ${FILE} == "file.txt" && ${MSG} == "Added the file as requested." ]]
    then
	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi
    echo ${RES}
    popd &> /dev/null
}

main $@
