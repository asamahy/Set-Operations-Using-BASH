#!/bin/bash

# Function to check membership in the set
s=;
function check_membership() {
  # $1 denotes the first argument passed to the function
   element=$1
  # $2 denotes the second argument passed to the function
   set=("${!2}")
# for each loop that iterates through the set
  for item in "${set[@]}"; do
    if [[ "$item" == "$element" ]]; then
      return 0
    fi
  done
  return 1
}

# set union
function set_union() {
   set1=("${!1}")
   set2=("${!2}")
   union_set=()

  # Add elements from set1 to the union set
  for element in "${set1[@]}"; do
      union_set+=("$element")
  done

  # check if the element is in set1 and if it is not in the union set
  # if it is not in the union set, add it to the union set
  for element in "${set2[@]}"; do
    if ! check_membership "$element" set1[@] && ! check_membership "$element" union_set[@]; then
      union_set+=("$element")
    fi
  done

  echo -e "Union Set: ${union_set[*]}\n" && sleep 1;
}

# set intersection
function set_intersection() {
   set1=("${!1}")
   set2=("${!2}")
   intersection_set=()

# Add elements from set1 that are also in set2
  for element in "${set1[@]}"; do
    if check_membership "$element" set2[@]; then
      intersection_set+=("$element")
    fi
  done

  echo -e "Intersection Set: ${intersection_set[*]}\n" && sleep 1;
}

# set difference
function set_difference() {
   set1=("${!1}")
   set2=("${!2}")
   difference_set=()

  # Add elements from set1 that are not in set2
  for element in "${set1[@]}"; do
    if ! check_membership "$element" set2[@]; then
      difference_set+=("$element")
    fi
  done

    echo -e "Difference Set: ${difference_set[*]}\n" && sleep 1;
}

# set complement
function set_complement() {
   set1=("${!1}")
   set2=("${!2}")
   complement_set=()

  # Add elements from set1 that are not in set2
  for element in "${set1[@]}"; do
    if ! check_membership "$element" set2[@]; then
      complement_set+=("$element")
    fi
  done

    echo -e "Complement to Set 2: ${complement_set[*]}\n" && sleep 1;
}

# insert an element into the set
function insert_element() {
   element=$1
   set1=("${!2}")

  if check_membership "$element" set1[@]; then
    echo -e "Element already exists in the set.\n" && sleep 1;
  else
    set1+=("$element")
    echo -e "Element added to the set.\n" && sleep 1;
  fi
}

# delete an element from the set
function delete_element() {
   element=$1
   set1=("${!2}")
   unset set2
   set2=("${!2}")

  if check_membership "$element" set1[@]; then
    for i in "${!set[@]}"; do
      if [[ "${set1[i]}" == "$element" ]]; then
        unset 'set1[i]'
        echo -e "Element deleted from the set.\n" && sleep 1;
        return
      fi
    done
  else
    echo -e "Element does not exist in the set.\n" && sleep 1;
  fi  
  
 if [[ "$s" == "true" ]]; then
  if check_membership "$element" set2[@]; then
    for i in "${!set2[@]}"; do
      if [[ "${set2[i]}" == "$element" ]]; then
        unset 'set2[i]'
        echo -e "Element deleted from the set.\n" && sleep 1;
        return
      fi
    done
  else
    echo -e "Element does not exist in the set.\n" && sleep 1;
  fi 
 fi
}

read -p "Enter the elements of Set 1 (space-separated): " -a set1

read -p "Enter the elements of Set 2 (space-separated): " -a set2

# menu function implementation
function menuPicker() {
    echo "${1}"; shift
    echo "$(tput dim)""- Change option: [up/down], Select: [ENTER]" "$(tput sgr0)"
     selected="${1}"; shift

    ESC=$(echo -e "\033")
    cursor_blink_on()  { tput cnorm; }
    cursor_blink_off() { tput civis; }
    cursor_to()        { tput cup $(($1-1)); }
    print_option()     { echo "$(tput sgr0)" "$1" "$(tput sgr0)"; }
    print_selected()   { echo "$(tput rev)" "$1" "$(tput sgr0)"; }
    get_cursor_row()   { IFS=';' read -rsdR -p $'\E[6n' ROW COL; echo "${ROW#*[}"; }
    key_input()        { read -rs -n3 key 2>/dev/null >&2; [[ $key = ${ESC}[A ]] && echo up; [[ $key = ${ESC}[B ]] && echo down; [[ $key = "" ]] && echo enter; }

    for opt; do echo; done

    local lastrow
    lastrow=$(get_cursor_row)
     startrow=$((lastrow - $#))
    trap "cursor_blink_on; echo; echo; exit" 2
    cursor_blink_off

    : selected:=0

    while true; do
         idx=0
        for opt; do
            cursor_to $((startrow + idx))
            if [ ${idx} -eq "${selected}" ]; then
                print_selected "${opt}"
            else
                print_option "${opt}"
            fi
            ((idx++))
        done

        case $(key_input) in
            enter) break;;
            up)    ((selected--)); [ "${selected}" -lt 0 ] && selected=$(($# - 1));;
            down)  ((selected++)); [ "${selected}" -ge $# ] && selected=0;;
        esac
    done

    cursor_to "${lastrow}"
    cursor_blink_on
    echo

    return "${selected}"
}

# main menu function implementation
function mainMenuList() {
    options=( "Check Membership" "Union of Sets" "Intersection of Sets" "Difference of Sets" "Complement to Set 2" "Insert Element to Set 1" "Delete Element from Set 1" "Insert Element to Set 2" "Delete Element from Set 2" "Exit");
    menuPicker "Choose:" 0 "${options[@]}"; choice=$?

    case "${options[$choice]}" in
        "Check Membership")
                # Prompt the user to enter the element to check membership
                read -p "Enter the element to check membership: " element
                if check_membership "$element" set1[@] ; then
                    echo -e "\n$element is a member of the set 1.\n"
                    sleep 1
                elif check_membership "$element" set2[@]; then
                    echo -e "\n $element is a member of the set 2.\n"
                    sleep 1
                else
                  echo -e "\n $element is not a member of a set.\n"
                  sleep 1
                fi
                mainMenuList;
        ;;
        "Union of Sets")
                set_union set1[@] set2[@];
                mainMenuList;
        ;;
        "Intersection of Sets")
                set_intersection set1[@] set2[@];
                mainMenuList;
        ;;
        "Difference of Sets")
               set_difference set1[@] set2[@];
                mainMenuList;
        ;;
        "Complement to Set 2")
                set_complement set1[@] set2[@];
                mainMenuList;
        ;;
        "Insert Element to Set 1")
                read -p "Enter the element to insert: " element
                insert_element "$element" set1[@];
                mainMenuList;
                ;;
        "Delete Element from Set 1")
                read -p "Enter the element to delete: " element
                delete_element "$element" set1[@];
                mainMenuList;
                ;;
        "Insert Element to Set 2")
                read -p "Enter the element to insert: " element
                insert_element "$element" set2[@];
                mainMenuList;
                ;;
        "Delete Element from Set 2")
        unset element;
                s="true";
                read -p "Enter the element to delete: " element
                delete_element "$element" set2[@];
                mainMenuList;
                ;;
        "Universal Set")

                read -p "Enter the elements of the Universal Set (space-separated): " -a universal_set
                mainMenuList2;                
                ;;
        "Exit")
                exit;
                ;;
    esac
}
function mainMenuList2() {
                        options=( "Check Membership" "Union of Sets" "Intersection of Sets" "Difference of Sets" "Insert Element to Set 1" "Delete Element from Set 1" "Exit");
                        menuPicker "Choose:" 0 "${options[@]}"; choice=$?

                        case "${options[$choice]}" in
                          "Check Membership")
                                  # Prompt the user to enter the element to check membership
                                  read -p "Enter the element to check membership: " element
                                  if check_membership "$element" universal_set[@] ; then
                                      echo -e "\n$element is a member of the Universal Set.\n"
                                      sleep 1
                                  else
                                      echo -e "\n $element is not a member of the Universal Set.\n"
                                      sleep 1
                                  fi
                                  mainMenuList2;
                          ;;
                          "Union of Sets")
                                  set_union universal_set[@] set1[@];
                                  mainMenuList2;
                          ;;
                          "Intersection of Sets")
                                  set_intersection set1[@] universal_set[@];
                                  mainMenuList2;
                          ;;
                          "Difference of Sets")
                                set_difference universal_set[@] set1[@];
                                  mainMenuList2;
                          ;;
                          "Insert Element to Set 1")
                                  read -p "Enter the element to insert: " element
                                  insert_element "$element" universal_set[@];
                                  mainMenuList2;
                                  ;;
                          "Delete Element from Set 1")
                                  read -p "Enter the element to delete: " element
                                  delete_element "$element" universal_set[@];
                                  mainMenuList2;
                                  ;;
                          "Exit")
                                  exit;
                                  ;;
                    
                        esac
                    }

# Start of program
mainMenuList;