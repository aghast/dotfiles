#!/usr/bin/env bash
#
# $DOTFILES/bash/deploy-bash.sh
#
# Script to "deploy" bash dotfiles to the current user's home directory.
# For linux, this creates symbolic links. For windows, it copies trampoline
# files.
#

dotfiles() {
	#
	# Set the DOTFILES variable, if it isn't already.
	#
	if [[ -z $DOTFILES ]]
	then
		local thisfile="${BASH_SOURCE[0]}"
		local thisdir="$(dirname "$thisfile")"
		local bashrc="${thisdir}/../bash/bashrc"
		
		if [[ -f $bashrc && -r $bashrc ]]
		then
			DOTFILES="$thisdir"
		fi
	fi

	if [[ -z $DOTFILES && -f "bash/bashrc" && -r "bash/bashrc" ]]
	then
		DOTFILES="$PWD"
	fi

	if [[ -z $DOTFILES ]]
	then
		printf "\nERROR: Unable to determine DOTFILES directory.\n" >&2
		printf "Set it by hand, or cd to the root of the dotfiles repo.\n" >&2
		exit 1
	fi
}

deploy_linux() {
	# 
	# This is mainly "deploy with symbolic links".
	#
	local source="$DOTFILES/bash"
	local target="$HOME"

	ln -s "$source/bashrc" "$target/.bashrc" 
	ln -s "$source/bash_logout" "$target/.bash_logout" 
	ln -s "$source/bash_profile" "$target/.bash_profile" 
}

deploy_windows() {
	#
	# This is mainly "deploy with no symbolic links".
	#
	local source_dir="$DOTFILES/bash"
	local target_dir="$HOME"

	for file in _bashrc _bash_logout _bash_profile
	do
		local source="$source_dir/$file"
		local target="$target_dir/$file"

		if [ -e "$target" ] 
		then
			printf "WARNING: '$target' already exists. Skipped." \
				>&2
		else
			sed -e "s/@DOTFILES@/$DOTFILES/g"	\
			< "$source" 				\
		       	> "$target"
		fi
	done
}

deploy_by_uname() {
	case "$(uname -s)" in
	*BSD)		deploy_linux	;; # FreeBSD or NetBSD (or ...?)
	Linux)		deploy_linux	;; # Linux
	CYGWIN_NT*)	deploy_windows	;; # cygwin
	Interix)	deploy_windows	;; # Windows Services for Unix
	Windows_NT)	deploy_windows	;; # busybox-w32
	MS-DOS)				   # djgpp
		printf "ERROR: Don't know how to deploy to MS-DOS!\n" >&2
		false
		;;  
	GNU*)				   # Debian GNU/HURD
		printf "ERROR: Don't know how to deploy on HURD!\n\n" >&2
		false
		;;
	*)				   # "other"
		printf "ERROR: Don't know how to deploy on $(uname -s)!\n" >&2
		false
		;;
	esac
}

main() {
	dotfiles
	deploy_by_uname
}

main "$@"

