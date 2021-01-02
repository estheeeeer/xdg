#!/bin/bash

phelp="Usage : xdg [-d|--directory] <format> : ouvre tous les fichiers du format spécifié\nxdg -d|--directory <directory> pour spécifier un directory où se trouvent les fichiers\nxdg --help|-h affiche ce message\n"
error="\e[31merreur :\e[0m"
no=0

open() {
	filesa=($(ls $2 ))
	case $1 in
	all)
		for i in $(seq 0 1 $(($(ls | wc -l)- 1)))
			do
			openall $2
			done
		;;
	some)
		for i in $(seq 0 1 $(($(ls | wc -l)- 1)))
				do
						opensome $2 $3 $i
				done
		if [[ "no" == "0" ]]
		then
			printf "$error aucun fichier trouvé de ce type\n"
		fi
		;;
	esac

}

openall() {
	printf "${filesa[$i]}: ouverture..."
	xdg-open "$1/${filesa[$i]}"
	if [ $? -ne 0 ]
        then
			printf "\n$error le fichier ${filesa[$i]} n'a pas pu être ouvert\n"
			printf "$(xdg-open '$1/${filesa[$i]}')"
            exit 1
    fi
	printf "\e[32mouvert\e[0m\n"
}

opensome() {
	format=$(file $1/${filesa[$i]}|grep -P -o "(?<=:).*")
	format=$(echo ${format,,})
	fu=$(echo ${2,,})
	if [[ $format == *$fu* ]]
        then
            openall $1 $i
	       return 0
	fi
	let no++
	return 1
}

directory() {
	unset dir[0]
	opt=${dir[-1]}
	unset dir[-1]
	for d in ${dir[@]}
	do
		if [ ! -d $d ]
		then
			printf "$error Le répertoire $d n'existe pas\n"
			exit 1
		fi
		if [[ "$opt" != "all" ]]
		then
			open some $d $opt
		else
			open all $d
		fi
	done
}

if [ $# -eq 0 ]||[ $# -eq 2 ]
then
	printf "$error trop peu d'arguments\n$phelp"
	exit 1
elif [ $# -gt 2 ]
then
	if [[ "$1" != "-d" ]]&&[[ "$1" != "--directory" ]]
	then
		printf "$error trop d'arguments\n$phelp"
		exit 1
	fi
fi

case $1 in
	all)
		open all $PWD;;
	-d|--directory)
		dir=( "$@" )
		directory $dir;;
	-h|--help) printf "$phelp";;
	*)
		open some $PWD $1;;
esac
