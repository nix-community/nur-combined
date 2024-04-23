#!/usr/bin/env bash
# view changes made between backups
backups=($(ls $1))
bkpath=($1)
r=$RAND

if [ ${#backups[@]} -eq 0 ]; then
    echo "No backups found."
    exit 1
fi

choose () {
    echo "Choose backup:"
    for ((i=0; i<${#backups[@]}; i++)); do
        echo "$((i+1)). ${backups[$i]}"
    done

    read -p "Enter the number of your choice: " choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please enter a number."
        exit 1
    fi

    if [ $choice -lt 1 ] || [ $choice -gt ${#backups[@]} ]; then
        echo "Invalid choice. Please enter a number within the valid range."
        exit 1
    fi
}

choose
chosen_file_1="${backups[$((choice-1))]}"
clear
choose
chosen_file_2="${backups[$((choice-1))]}"
clear

files1=$(ls $bkpath/$chosen_file_1/)
files2=$(ls $bkpath/$chosen_file_2/)

if [ ${#array1[@]} -lt ${#array2[@]} ]; then
    size=${#files1[@]}
else
    size=${#files2[@]}
fi

for (( i=0; i<size; i++ )); do
    one=${array[$i]}
    two=${array[$i]}
    git diff $bkpath/$chosen_file_1/$one $bkpath/$chosen_file_2/$two
done
