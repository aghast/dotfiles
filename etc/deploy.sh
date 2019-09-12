#!/bin/sh

if [ -z "$DOTFILES" ]
then
	printf "ERROR: The DOTFILES environment variable is not set!\n" >&2
	printf "Set it to the root of the dotfiles project.\n\n" >&2
	exit 1
fi

ETC_PATH=${ETC_PATH:-$(dirname "$(readlink -f "$0")")}

get_shellname() {
	shell="${1:-$(getent passwd "$LOGNAME" | cut -d: -f7)}"
	whatshell=$("$shell" "$DOTFILES/etc/whatshell.sh")
	set -- $whatshell

	whatshell="$1"
	if [ "$whatshell" = "ash" -a "$(uname -s)" = 'Linux'* ]
	then
		whatshell=dash
	fi

	printf "$whatshell"
}

deploy() {
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

deploy $1
