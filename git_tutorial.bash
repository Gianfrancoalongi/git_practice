#!/bin/bash

main()
{
   print_welcome
   select option in start resume help quit; do
      case $option in 
         start)
            echo "scenario_01.bash" > current_scenario.txt
            run_tutorial
         ;;
         resume)
            run_tutorial
         ;;
         help)
            print_help
            echo "--"
            print_welcome
         ;;
         quit)
            echo "-- git-tutorial --"
            break;
         ;;
      esac
   done
}

good_bye()
{
   echo "hej då!"
}

print_help()
{
   cat README.md
   cat <<EOF
===
This tutorial, will guide you through all the defined exercises...
EOF
}

print_welcome()
{
         cat <<EOF
Welcome to git-tutorial. From this menu you can start a new tutorial session,
resume an already started session, read and learn about this tutorial, or just
quit and come later.
EOF
}

get_current_scenario()
{
   if [ ! -e current_scenario.txt ]; then
      echo "scenario_01.bash" > current_scenario.txt
   fi
   cat current_scenario.txt
}

set_current_scenario()
{
   echo ${1} > current_scenario.txt   
}

get_next_scenario()
{
   SCENARIO=$(get_current_scenario)
   MAXLEVEL=$(get_last_level)
   NUM=$(get_level_from_scenario $SCENARIO)
   NUM=$((($NUM % $MAXLEVEL) + 1))
   get_scenario_from_level $NUM 
}

get_previous_scenario()
{
   SCENARIO=$(get_current_scenario)
   NUM=$(get_level_from_scenario $SCENARIO)
   if [ $NUM -gt 1 ]; then
      NUM=$(($NUM - 1)) 
   else
      echo "You're already in the minimum level."
   fi
   get_scenario_from_level $NUM 
}

get_last_level()
{
   LAST=$(ls scenario_*.bash | tail -n 1)
   get_level_from_scenario $LAST 
}

get_level_from_scenario ()
{
   echo ${1} | sed 's/scenario_\([^\.]*\).bash/\1/'
}

get_scenario_from_level ()
{
   echo ${1} | awk '{ printf "scenario_%02d.bash\n", $1 }'
}

run_tutorial()
{
   select option in next previous show-current-level list-progress repeat finish; do
      echo "Select one of the following options:"
      case $option in 
         next)
            nextLevel=$(get_next_scenario)
            set_current_scenario $nextLevel
            run_scenario $nextLevel
         ;;
         previous)
            previousLevel=$(get_previous_scenario)
            set_current_scenario $previousLevel
            run_scenario $previousLevel
         ;;
         repeat)
            echo "repeating level $(get_current_scenario)"
            run_scenario $(get_current_scenario)
         ;;
         finish)
            echo "Farewell traveler, till the time our paths encounter again."
            break
         ;;
         show-current-level)
            echo "You're currently at level $(get_current_scenario)"
         ;;
         list-progress)
            echo "not implemented yet."
         ;;
   done
}

run_scenario()
{
   echo "not implemented yet"
}
