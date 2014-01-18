#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_name_was_properly_changed_for_the_remote ${2}
    else
	setup_scenario &> /dev/null
	generate_description_file
	generate_help_file
        bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d)
    SCENARIO_REMOTE_GIT_REPO=$(mktemp -d)
    pushd ${SCENARIO_REMOTE_GIT_REPO}
    git init .
    touch {a,b,c,d}.txt 
    git add {a,b,c,d}.txt
    git commit -m 'initial commit'
    echo 'A is for algorithms' > a.txt && git commit -a -m 'Finished A'
    echo 'B is for bits' > b.txt && git commit -a -m 'Finished B'
    popd
    pushd ${SCENARIO_GIT_REPO}
    git init .
    touch {c,d}.txt
    git add {c,d}.txt
    git commit -m 'initial commit'
    echo 'C is for ciphers' > c.txt && git commit -a -m 'Finished C'
    echo 'D is for decryption' > d.txt && git commit -a -m 'Finished D'
    git remote add the_remote_repository ${SCENARIO_REMOTE_GIT_REPO}
    git fetch the_remote_repository
    popd
    echo ${SCENARIO_GIT_REPO} > repository.txt
    echo ${SCENARIO_REMOTE_GIT_REPO} > remote_repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Change the shortname of the remote which was added to your git
scenario repository. Current name is 'the_remote_repository'
change this to 'other_repository'.
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 2.5 Git Basics - Working with Remotes
Git man page: git help remote
EOF
}

check_that_name_was_properly_changed_for_the_remote() {
    pushd ${1} &> /dev/null
    FACIT_FILE_BRANCH=$(mktemp)
    ACTUAL_FILE_BRANCH=$(mktemp)
    FACIT_FILE_LOG=$(mktemp)
    ACTUAL_FILE_LOG=$(mktemp)
    cat > ${FACIT_FILE_BRANCH} <<EOF
* master
  remotes/other_repository/master
EOF
    cat > ${FACIT_FILE_LOG} <<EOF
* Finished D
* Finished C
* initial commit
* Finished B
* Finished A
* initial commit
EOF
    git branch -a &> ${ACTUAL_FILE_BRANCH}
    git log master --graph --format="%s" &>> ${ACTUAL_FILE_LOG}
    git log other_repository/master --graph --format="%s" &>> ${ACTUAL_FILE_LOG}

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
