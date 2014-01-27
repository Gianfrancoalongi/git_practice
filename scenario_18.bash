#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_third_commit_was_removed $2
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
    cat > lines.txt <<EOF
1. ----------
2. ----------
3. ----------
4. ----------
5. ----------
6. ----------
7. ----------
8. ----------
9. ----------
EOF
    git add lines.txt
    git commit -m 'first commit'
    TMP=$(mktemp)
    sed 's/1.*/1. ++++++++++/g' lines.txt > ${TMP} && mv ${TMP} lines.txt
    git commit -a -m 'positive on 1'
    sed 's/3.*/3. ++++++++++/g' lines.txt > ${TMP} && mv ${TMP} lines.txt
    git commit -a -m 'positive on 3'
    sed 's/5.*/5. ++++++++++/g' lines.txt > ${TMP} && mv ${TMP} lines.txt
    git commit -a -m 'positive on 5'
    sed 's/7.*/7. ++++++++++/g' lines.txt > ${TMP} && mv ${TMP} lines.txt
    git commit -a -m 'positive on 7'
    sed 's/9.*/9. ++++++++++/g' lines.txt > ${TMP} && mv ${TMP} lines.txt
    git commit -a -m 'positive on 9'
    popd
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Remove the commit that set line 5 to positive in lines.txt
Do this by using interactive rebase (rebase -i ....)
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 6.4 Git Tools - Rewriting History
EOF
}

check_that_third_commit_was_removed() {
    pushd ${1} &> /dev/null
    FACIT_FILE=$(mktemp)
    cat > ${FACIT_FILE} <<EOF    
1. ++++++++++
2. ----------
3. ++++++++++
4. ----------
5. ----------
6. ----------
7. ++++++++++
8. ----------
9. ++++++++++
EOF
    FACIT_BRANCH=$(mktemp)
    cat > ${FACIT_BRANCH} <<EOF
* master
EOF
    FACIT_LOG=$(mktemp)
    cat > ${FACIT_LOG} <<EOF
positive on 9
positive on 7
positive on 3
positive on 1
first commit
EOF
    ACTUAL_FILE=$(mktemp)
    cat lines.txt > ${ACTUAL_FILE}
    ACTUAL_BRANCH=$(mktemp)
    git branch > ${ACTUAL_BRANCH}
    ACTUAL_LOG=$(mktemp)
    git log --format='%s' > ${ACTUAL_LOG}

    diff -E -b ${FACIT_FILE} ${ACTUAL_FILE} &> /dev/null
    R1=$? 
    diff -E -b ${FACIT_BRANCH} ${ACTUAL_BRANCH} &> /dev/null
    R2=$? 
    diff -E -b ${FACIT_LOG} ${ACTUAL_LOG} &> /dev/null
    R3=$? 
    
    if [[ ${R1} == ${R2} && ${R2} == ${R3} && ${R3} == 0 ]]
    then
    	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi

    rm ${FACIT_FILE} ${ACTUAL_FILE} \
       ${FACIT_BRANCH} ${ACTUAL_BRANCH} \
       ${FACIT_LOG} ${ACTUAL_LOG} &> /dev/null
    popd &> /dev/null
    echo ${RES}
}

main $@
