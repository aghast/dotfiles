#!/bin/sh

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

main() {
	require_dotfiles
	local linktype="$(links_or_copies)"

	if [ -z "$linktype" ] 
	then
		return 1
	fi

	deploy_ctags $linktype
	deploy_git $linktype
	deploy_inputrc $linktype
}

main
