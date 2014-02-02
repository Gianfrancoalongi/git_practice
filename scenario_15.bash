#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_spelling_corrections_where_pushed_to_remote ${2}
    else
	setup_scenario &> /dev/null
	generate_description_file
	generate_help_file
        bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d /tmp/GITPractice_Repo_XXXXXXXX)
    SCENARIO_REMOTE_GIT_REPO=$(mktemp -d /tmp/GITPractice_REMOTE_REPO_XXXXXXXX)
    pushd ${SCENARIO_REMOTE_GIT_REPO}
    git init .
    cat > message.txt <<EOF
this is a piece of engrish text with
some spellllling errors inculded here and
theer.
EOF
    git add message.txt
    git commit -m 'first version of message'
    popd
    pushd ${SCENARIO_GIT_REPO}
    git init .
    git remote add the_remote_repository ${SCENARIO_REMOTE_GIT_REPO}
    git pull the_remote_repository master
    git checkout -b fixed_spelling
    cat > message.txt <<EOF
this is a piece of english text with
some spelling errors included here and
there.
EOF
    popd
    echo ${SCENARIO_GIT_REPO} > repository.txt
    echo ${SCENARIO_REMOTE_GIT_REPO} > remote_repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
(1) Commit the spelling corrections.
(2) Push the fix on 'fixed_spelling' branch back to the remote 
    named 'the_remote_repository'.
You can verify that you have successfully performed the push by 
issuing the command 'gitk --all' in the remote repository.
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 3.5 Git Branching - Remote Branches
Git man pages: git help push
               git help remote
EOF
}

check_that_spelling_corrections_where_pushed_to_remote() {
    REMOTE=$(cat remote_repository.txt)
    pushd ${1} &> /dev/null
    FACIT_FILE_MESSAGE=$(mktemp /tmp/XXXXXXXX)
    cat message.txt  > ${FACIT_FILE_MESSAGE}
    FACIT_FILE_BRANCH=$(mktemp /tmp/XXXXXXXX)
    git branch  > ${FACIT_FILE_BRANCH}
    popd &> /dev/null
    pushd ${REMOTE} &> /dev/null
    git checkout fixed_spelling &> /dev/null
    ACTUAL_FILE_MESSAGE=$(mktemp /tmp/XXXXXXXX)
    cat message.txt > ${ACTUAL_FILE_MESSAGE}
    ACTUAL_FILE_BRANCH=$(mktemp /tmp/XXXXXXXX)    
    git branch -a &> ${ACTUAL_FILE_BRANCH}
    diff -E -b ${FACIT_FILE_MESSAGE} ${ACTUAL_FILE_MESSAGE} &> /dev/null
    R1=$? 
    diff -E -b ${FACIT_FILE_BRANCH} ${ACTUAL_FILE_BRANCH} &> /dev/null
    R2=$?

    if [[ ${R1} == ${R2} && ${R2} == 0 ]]
    then
	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi
    rm -f ${FACIT_FILE_BRANCH} \
	  ${ACTUAL_FILE_BRANCH} \
	  ${FACIT_FILE_MESSAGE} \
	  ${ACTUAL_FILE_MESSAGE} &> /dev/null
    popd &> /dev/null
    echo ${RES}
}

main $@
