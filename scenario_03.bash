#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_configuration_is_properly_written $2
    else
	setup_scenario &> /dev/null
	generate_description_file
	generate_help_file
	bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d GITPractice_XXXXXXXX)
    pushd ${SCENARIO_GIT_REPO}
    git init .
    popd
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
