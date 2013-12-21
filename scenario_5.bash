#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_b_is_not_staged_for_commit $2
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
    touch {a,b,c}.txt
    git add {a,b,c}.txt
    git commit -m 'First commit'
    for i in {a,b,c}.txt; do echo 'change' >> ${i}; done    
    popd &> /dev/null
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Change so that b.txt is not staged for commit.
Only a.txt and c.txt should be staged for commit, so that
the command

    git commit -m 'Second commit'

should only include the changes in a.txt and c.txt

You can find the repository location in the file named 
    repository.txt
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 2.4 Git Basics - Undoing Things
 subchapter Unstaging a Staged File
EOF
}

check_that_file_is_reset_in_index() {
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
