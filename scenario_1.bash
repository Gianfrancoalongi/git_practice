#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_if_empty_git_repository_exists_at $2
    else
	generate_description_file
	generate_help_file
	show_scenario_text
    fi
}

show_scenario_text() {
    cat <<EOF
Scenario set up.
Read description.txt to know what you need to do.
Run this script as
       $0 --verify PATH_TO_YOUR_REPOSITORY
when you think you are done
EOF
}

generate_description_file() {
    cat > description.txt <<EOF
This is the most basic scenario - you have to set up an empty git repository.
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
You can read Chapter 2.1 Git Basics - Getting a Git Repository for help
EOF
}

check_if_empty_git_repository_exists_at() {
    pushd $1 &> /dev/null
    STATUS=$(git status | grep "\# Initial commit")
    if [[ ${STATUS} == "# Initial commit" ]]
    then
	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi
    echo ${RES}
    popd &> /dev/null
}

main $@
