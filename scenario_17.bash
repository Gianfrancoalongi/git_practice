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
    SCENARIO_GIT_REPO=$(mktemp -d)
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
    RES="No - you are not done"
    echo ${RES}
}

main $@
