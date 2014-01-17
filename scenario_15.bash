#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_spelling_corrections_where_pushed_to_remote ${2}
    else
	setup_scenario
	generate_description_file
	generate_help_file
        bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d)
    SCENARIO_REMOTE_GIT_REPO=$(mktemp -d)
    pushd ${SCENARIO_REMOTE_GIT_REPO} &> /dev/null
    git init . &> /dev/null
    echo > message.txt <<EOF
this is a piece of engrish text with
some spellllling errors inculded here and
theer.
EOF
    git add message.txt
    git commit -m 'first version of message' &> /dev/null
    popd &> /dev/null
    pushd ${SCENARIO_GIT_REPO} &> /dev/null
    git init . &> /dev/null
    git remote add the_remote_repository ${SCENARIO_REMOTE_GIT_REPO} &> /dev/nul
    git pull the_remote_repository &> /dev/null
    git checkout -b fixed_spelling &> /dev/null
    echo > message.txt <<EOF
this is a piece of english text with
some speling errors included here and
there.
EOF
    popd &> /dev/null
    echo ${SCENARIO_GIT_REPO} > repository.txt
    echo ${SCENARIO_REMOTE_GIT_REPO} > remote_repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
-----------------------------------------------------------------
(1) Add the repository in ${SCENARIO_REMOTE_GIT_REPO} as a remote
(2) Commit the spelling corrections and push the 'fixed_spelling'
    branch to the remote repository so that your team mates can 
    look at it and continue. 
You can verify that you have successfully performed the push by 
issuing the command 'gitk --all' in the remote repository.
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 3.5 Git Branching - Remote Branches
Git man page: git help push
EOF
}

check_that_spelling_corrections_where_pushed_to_remote() {
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
