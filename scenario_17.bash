#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_changes_where_stashed_and_branch_changed $2
    else
	setup_scenario &> /dev/null
	generate_description_file
	generate_help_file
	bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d GITPractice_Repo_XXXXXXXX)
    pushd ${SCENARIO_GIT_REPO}
    git init .
    touch {a,b}.txt
    git add {a,b}.txt
    git commit -m 'First commit'
    echo '1st change on b' >> b.txt
    git stash
    echo '2nd change on b' >> b.txt
    git stash
    echo '3rd change on b' >> b.txt
    git stash
    git checkout -b test
    echo 'changes in a' >> a.txt
    popd
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Stash the changes on the branch 'test' and switch to the master
branch. On the master branch, apply the stash with index 1.
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 6.3 Git Tools - Stashing
EOF
}

check_that_changes_where_stashed_and_branch_changed() {
    pushd ${1} &> /dev/null
    FACIT_FILE=$(mktemp /tmp/XXXXXXXX)
    cat > ${FACIT_FILE} <<EOF    
3rd change on b
EOF
    FACIT_BRANCH=$(mktemp /tmp/XXXXXXXX)
    cat > ${FACIT_BRANCH} <<EOF
* master
  test
EOF
    FACIT_STASH=$(mktemp /tmp/XXXXXXXX)
    cat > ${FACIT_STASH} <<EOF
stash@{0}: test:
stash@{1}: master:
stash@{2}: master:
stash@{3}: master:
EOF
    FACIT_ZERO=$(mktemp /tmp/XXXXXXXX)
    cat > ${FACIT_ZERO} <<EOF
 a.txt |    1 +
 1 file changed, 1 insertion(+)
EOF
    ACTUAL_FILE=$(mktemp /tmp/XXXXXXXX)
    cat b.txt > ${ACTUAL_FILE}
    ACTUAL_BRANCH=$(mktemp /tmp/XXXXXXXX)
    git branch > ${ACTUAL_BRANCH}
    ACTUAL_STASH=$(mktemp /tmp/XXXXXXXX)
    git stash list | cut -d ' ' -f 1,4 > ${ACTUAL_STASH}
    ACTUAL_ZERO=$(mktemp /tmp/XXXXXXXX)
    git stash show stash@{0} > ${ACTUAL_ZERO}

    diff -E -b ${FACIT_FILE} ${ACTUAL_FILE} &> /dev/null
    R1=$? 
    diff -E -b ${FACIT_BRANCH} ${ACTUAL_BRANCH} &> /dev/null
    R2=$? 
    diff -E -b ${FACIT_STASH} ${ACTUAL_STASH} &> /dev/null
    R3=$? 
    diff -E -b ${FACIT_ZERO} ${ACTUAL_ZERO} &> /dev/null
    R4=$?
    
    if [[ ${R1} == ${R2} && ${R2} == ${R3} && ${R3} == ${R4} && ${R4} == 0 ]]
    then
    	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi

    rm ${FACIT_FILE} ${ACTUAL_FILE} \
       ${FACIT_BRANCH} ${ACTUAL_BRANCH} \
       ${FACIT_STASH} ${ACTUAL_STASH} \
       ${FACIT_ZERO} ${ACTUAL_ZERO} &> /dev/null
    popd &> /dev/null
    echo ${RES}
}

main $@
