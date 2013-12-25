#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_branch_was_merged_and_deleted ${2}
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
    touch a.txt
    git add a.txt
    git commit -m 'Initial commit'
    git checkout -b ahead_of_master
    echo 'line one' >> a.txt && git commit -a -m 'One step ahead'
    echo 'line two' >> a.txt && git commit -a -m 'Two steps ahead'
    echo 'line three' >> a.txt && git commit -a -m 'Three steps ahead'
    popd &> /dev/null
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Merge the branch 

    ahead_of_master 

into the master branch and delete the branch

    ahead_of_master

so that only the master branch exists with the
merged content.

You can find the repository location in the file named 
    repository.txt
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 3.2 Git Branching - Basic Branching and Merging
 subchapter Basic Merging
EOF
}

check_that_branch_was_merged_and_deleted() {
    pushd ${1} &> /dev/null
    FACIT_FILE=$(mktemp)
    ACTUAL_FILE=$(mktemp)
    cat > ${FACIT_FILE} <<EOF
  master
* my_branch
EOF
    git branch &> ${ACTUAL_FILE}
    diff -E -b ${FACIT_FILE} ${ACTUAL_FILE} &> /dev/null
    if [[ $? == 0 ]]
    then
	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi
    rm -f ${FACIT_FILE} ${ACTUAL_FILE} &> /dev/null
    popd &> /dev/null
    echo ${RES}
}

main $@
