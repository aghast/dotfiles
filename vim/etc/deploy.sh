#!/bin/sh
# shellcheck disable=SC2039

# shellcheck source=../../etc/deploy-functions.sh
. "$DOTFILES/etc/deploy-functions.sh"

## CTAGS

deploy_ctags() {
	local ctags_file="$DOTFILES/vim/etc/ctags"

	require_file "$ctags_file" || return 1

	case "$1" in
	links)	
		symlink "$ctags_file" "$HOME/.ctags"
		;;
	copies)	
		cp -ab "$ctags_file" "$HOME/ctags.cnf" \
		|| ERROR "Failed to copy ~/ctags.cnf <- $ctags_file" 
		;;
	esac
}

## VIMRC & GVIMRC

deploy_vimrc() {
	local vimrc_file="$DOTFILES/vim/etc/_vimrc"
	local gvimrc_file="$DOTFILES/vim/etc/_gvimrc"

	require_file "$vimrc_file" || return 1
	require_file "$gvimrc_file" || return 1

	case "$1" in
	links)	
		symlink "$vimrc_file" "$HOME/.vimrc"
		symlink "$gvimrc_file" "$HOME/.gvimrc"
		;;
	copies)	
		cp -ab "$vimrc_file" "$HOME/_vimrc" \
		|| ERROR "Failed to copy ~/_vimrc <- $vimrc_file" 
		cp -ab "$gvimrc_file" "$HOME/_gvimrc" \
		|| ERROR "Failed to copy ~/_gvimrc <- $gvimrc_file" 
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

	printf " * deploying VIM files\n"

	deploy_ctags $linktype
	deploy_vimrc $linktype
}

main
