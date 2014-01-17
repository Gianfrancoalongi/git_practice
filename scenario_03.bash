#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_configuration_is_properly_written $2
    else
	setup_scenario
	generate_description_file
	generate_help_file
	show_scenario_text
    fi
}

show_scenario_text() {
    cat <<EOF
=================================================================
Your scenario GIT repository is in ${SCENARIO_GIT_REPO}
=================================================================
EOF
cat description.txt
cat <<EOF
=================================================================
Recommended reading in Pro Git            http://git-scm.com/book
EOF
cat help.txt
cat <<EOF
=================================================================
Run this script as
       bash $0 --verify ${SCENARIO_GIT_REPO}
when you think you are done
=================================================================
You can always read 
    description.txt To know what you need to do
    help.txt        To get Pointers on what to read
    repository.txt  To see where the scenario GIT repository is
=================================================================
EOF
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d)
    pushd ${SCENARIO_GIT_REPO} &> /dev/null
    git init . &> /dev/null
    popd &> /dev/null
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Configure the git repository locally so that 
 (1) the editor is set to emacs in no-window mode, that is 
     emacs -nw
 (2) the merge tool is configured to kdiff3
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 1.5 Getting Started - First Time Git Setup
EOF
}

check_that_configuration_is_properly_written() {
    pushd $1 &> /dev/null
    if [[ ($(git config --local core.editor) == "emacs -nw") &&  
		($(git config --local merge.tool) ==  "kdiff3") ]]
    then
	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi
    echo ${RES}
    popd &> /dev/null
}

main $@
