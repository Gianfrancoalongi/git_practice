#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_last_commit_message_is_amended $2
    else
	setup_scenario
	generate_description_file
	generate_help_file
	bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d)
    pushd ${SCENARIO_GIT_REPO} &> /dev/null
    git init . &> /dev/null
    touch file.txt &> /dev/null
    git add file.txt &> /dev/null
    git commit -m 'Wrong commit message.' &> /dev/null
    popd &> /dev/null
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Change the commit message of the last commit (amend the commit).
The correct message is 'Correct commit message.'
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 2.4 Git Basics - Undoing Things
 subchapter Changing Your Last Commit
EOF
}

check_that_last_commit_message_is_amended() {
    pushd ${1} &> /dev/null
    FACIT_FILE=$(mktemp)
    ACTUAL_FILE=$(mktemp)
    cat > ${FACIT_FILE} <<EOF
Correct commit message.
EOF
    git log --pretty=oneline | cut -d ' ' -f 2- &> ${ACTUAL_FILE}
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
