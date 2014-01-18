#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_branch_was_merged_and_deleted ${2}
    else
	setup_scenario &> /dev/null
	generate_description_file
	generate_help_file
	bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d)
    pushd ${SCENARIO_GIT_REPO}
    git init .
    touch a.txt
    git add a.txt
    git commit -m 'Initial commit'
    git checkout -b ahead_of_master
    echo 'line one' >> a.txt && git commit -a -m 'One step ahead'
    echo 'line two' >> a.txt && git commit -a -m 'Two steps ahead'
    echo 'line three' >> a.txt && git commit -a -m 'Three steps ahead'
    popd
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Merge the branch 'ahead_of_master' into the master branch and 
delete the branch 'ahead_of_master' so that only the master branch 
exists with the merged content.
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
    FACIT_FILE_BRANCH=$(mktemp)
    ACTUAL_FILE_BRANCH=$(mktemp)
    FACIT_FILE_LOG=$(mktemp)
    ACTUAL_FILE_LOG=$(mktemp)
    cat > ${FACIT_FILE_BRANCH} <<EOF
* master
EOF
    cat > ${FACIT_FILE_LOG} <<EOF
Three steps ahead
Two steps ahead
One step ahead
Initial commit
EOF
    git branch &> ${ACTUAL_FILE_BRANCH}
    git log --pretty=oneline | cut -d ' ' -f 2- &> ${ACTUAL_FILE_LOG}

    diff -E -b ${FACIT_FILE_BRANCH} ${ACTUAL_FILE_BRANCH} &> /dev/null
    R1=$?    
    diff -E -b ${FACIT_FILE_LOG} ${ACTUAL_FILE_LOG} &> /dev/null
    R2=$?

    if [[ ${R1} == ${R2} && ${R2} == 0 ]]
    then
	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi
    rm -f ${FACIT_FILE_BRANCH} \
	  ${ACTUAL_FILE_BRANCH} \
	  ${FACIT_FILE_LOG} \
	  ${ACTUAL_FILE_LOG} &> /dev/null
    popd &> /dev/null
    echo ${RES}
}

main $@
