#!/bin/sh

ETC_PATH=${ETC_PATH:-$(dirname "$(readlink -f "$0")")}

# FIXME: Switch this to computing dotfiles from etc_path, above.
if [ -z "$DOTFILES" ]
then
	DOTFILES="${ETC_PATH%/*}"
	echo "DOTFILES=$DOTFILES"
	exit 1
fi

. "$DOTFILES/etc/deploy-functions.sh"

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

deploy_inputrc() {
	local config_file="$DOTFILES/etc/_inputrc"
	require_file "$config_file" || return 1

	case "$1" in
	links)	
		symlink "$config_file" "$HOME/.inputrc"
		;;
	copies)	
		cp -ab "$config_file" "$HOME/_inputrc" \
		|| ERROR "Failed to copy ~/_inputrc <- $config_file" 
		;;
	*) 
		ERROR "Invalid link/copy type: '$1'" 
		;;
	esac
}

deploy_shell() {
	local shellname=""	# Not POSIX. Comment it out if you need to.
	local deploy_script=""

	shellname=$(get_shellname $1)
	deploy_script="$DOTFILES/$shellname/deploy-$shellname.sh"
	
	if [ -f "$deploy_script" ]
	then
		. "$deploy_script"
	else
		printf "ERROR: No $deploy_script script found\n\n" >&2
	fi
}

#
# Deploy a subsystem stored in a subdirectory below $DOTFILES.
#
deploy_subdir() {
	local subdir="${1}"

	if [ -z "$subdir" ] || [ ! -d "$subdir" ]
	then
		printf "Usage: deploy_subdir DIR" >&2
		return 1
	fi

	( cd "$subdir" && ./etc/deploy.sh )
}

get_shellname() {
	shell="${1:-$(getent passwd "$LOGNAME" | cut -d: -f7)}"
	whatshell=$("$shell" "${ETC_PATH}/whatshell.sh")
	set -- $whatshell

	whatshell="$1"
	if [ "$whatshell" = "ash" -a "$(uname -s)" = 'Linux'* ]
	then
		whatshell=dash
	fi

	printf "$whatshell"
}


main() {
	require_dotfiles
	local linktype="$(links_or_copies)"

	if [ -z "$linktype" ] 
	then
		return 1
	fi

	deploy_git $linktype
	deploy_inputrc $linktype
	deploy_shell $1
	deploy_subdir "vim"
}

main
