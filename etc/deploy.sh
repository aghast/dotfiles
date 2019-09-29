#!/bin/sh

## CTAGS

deploy_ctags() {
	local ctags_file="$DOTFILES/etc/ctags"

	require_file "$ctags_file" || return 1

	case "$1" in
	links)	
		symlink "$ctags_file" "$HOME/.ctags"
		;;
	copies)	
		cp -ab "$ctags_file" "$HOME/ctags.cnf" \
		|| ERROR "Failed to copy ~/ctags.cnf <- $ctags_file" 
		;;
	*) 
		ERROR "Invalid link/copy type: '$1'" 
		;;
	esac
}

deploy_git() {
	local config_file="$DOTFILES/etc/gitconfig"
	require_file "$config_file" || return 1

	local ignore_file="$DOTFILES/etc/cvsignore"
	require_file "$ignore_file" || return 1

	case "$1" in
	links)	
		symlink "$config_file" "$HOME/.gitconfig"
		symlink "$ignore_file" "$HOME/.cvsignore"
		;;
	copies)	
		cp -ab "$config_file" "$HOME/.gitconfig" \
		|| ERROR "Failed to copy ~/.gitconfig <- $config_file" 
		cp -ab "$ignore_file" "$HOME/.cvsignore" \
		|| ERROR "Failed to copy ~/.cvsignore <- $ignore_file" 
		;;
	*) 
		ERROR "Invalid link/copy type: '$1'" 
		;;
	esac
}

#################################################

ERROR() {
	printf "ERROR: " >&2
	printf "$*\n" >&2
	return 1
}

links_or_copies() {
	case "$(uname -s)" in
	*BSD)		printf "links\n"	;; # FreeBSD or NetBSD (or ...?)
	Linux)		printf "links\n"	;; # Linux
	CYGWIN_NT*)	printf "copies\n"	;; # cygwin
	Interix)	printf "copies\n"	;; # Windows Services for Unix
	Windows_NT)	printf "copies\n"	;; # busybox-w32
	MS-DOS)				   # djgpp
		printf "ERROR: Don't know how to deploy to MS-DOS!\n" >&2
		return 1
		;;  
	GNU*)				   # Debian GNU/HURD
		printf "ERROR: Don't know how to deploy on HURD!\n\n" >&2
		return 1
		;;
	*)				   # "other"
		printf "ERROR: Don't know how to deploy on $(uname -s)!\n" >&2
		return 1
		;;
	esac

	return 0
}


main() {
	if [ -z "$DOTFILES" ] || [ ! -d "$DOTFILES" ]
	then
		printf "ERROR: \$DOTFILES is not set, or directory missing." >&2
		return 1
	fi

	local linktype="$(links_or_copies)"

	if [ -z "$linktype" ] 
	then
		return 1
	fi

	deploy_ctags $linktype
	deploy_git $linktype
}

require_file() {
	if [ -f "$1" ]
	then
		: return true
	else
		ERROR "'$1' missing"
	fi
}

symlink() {
	local target="$1"	# Pointed to by link
	local link="$2"		# Link -> target

	if [ -e "$link" ]
	then
		if [ -h "$link" ]
		then
			rm "$link" \
			|| ERROR "Could not remove existing symlink '$link'"
		else
			ERROR "File '$link' blocks creation of symlink."
		fi

		if [ $? -ne 0 ]
		then
			return 1
		fi
	fi

	if ln -s "$target" "$link"
	then
		return 0
	else
		ERROR "Failed to link '$link' -> '$target'"
		return 1
	fi
}

main
