#
# CHROOT IN PROMPT (DEBIAN) {{{
#

add_chroot_to_prompt() {
	if [ -z "${debian_chroot:-}" -a -r /etc/debian_chroot ]
	then
		debian_chroot="$(cat /etc/debian_chroot)"
	fi

	# Note single-quotes here. Variable expansion delayed.
	PS1='${debian_chroot:+($debian_chroot)}\u\@\h:\w\$ '
}

add_chroot_to_prompt

# }}}

#
# COLOR(s) {{{
#
set_color_prompt() {
	local color_prompt=false

	local prompt='$ '

	[ $(id -u) -eq 0 ] && prompt='# '

	case "$TERM" in
	*-color|*-256color) color_prompt=true ;;
	esac

	force_color_prompt="${force_color_prompt:-false}"

	if $force_color_prompt
	then
		if [ -x /usr/bin/tput ] && tput setaf 1 > /dev/null 2>&1
		then
			# Colors OK!
			color_prompt=true
		else
			color_prompt=false
		fi
	fi
	
	local E="$(printf "\e.")"
	E="${E%?}"

	if $color_prompt
	then
		PS1='${debian_chroot:+($debian_chroot)}'"${E}"'[01;32m${USER}@${HOSTNAME}'"${E}"'[00m:'"${E}"'[01;34m${PWD}'"${E}"'[00m'"$prompt"
	else
		PS1='${debian_chroot:+($debian_chroot)}${USER}@${HOSTNAME}:${PWD}'"$prompt"
	fi

	unset force_color_prompt
}

add_color_support() {
	set_color_prompt

	if [ -x /usr/bin/dircolors ]
	then
		test -r ~/.dircolors \
			&& eval "$(dircolors -b ~/.dircolors)" \
			|| eval "$(dircolors -b)"

		alias ls='ls --color=auto'
		alias grep='grep --color=auto'
		alias egrep='egrep --color=auto'
		alias fgrep='fgrep --color=auto'
	fi

	export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
}

add_color_support

# }}}

#
# PATH FUNCTIONS {{{
#
path() {
	local pathvar="${1:-PATH}"
	printf "Directories in $pathvar:\n"

	local pathitems
	eval "pathitems=\"\$${pathvar}\""

	printf "${pathitems}x\n" \
	| tr ':' "\n" \
	| sed -e '$d' \
	| nl -n rz -s ": " -w2
}


# }}}

#
# WINDOW TITLES {{{
#

set_window_title() {
	case "$TERM" in
	xterm*|rxvt*|gnome-*)
		PROMPT_COMMAND='printf "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
		;;
	esac
}

set_window_title

# }}}

#
# LESS PAGER SETTINGS {{{
#

less_pager_settings() {
	# make less more friendly for non-text input files, see lesspipe(1)
	[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
	export LESS="-iq"
}

less_pager_settings
# }}}

#
# Pyenv python-version management tool {{{
#

case "$PATH" in
*:"$HOME"/.pyenv/shims:* ) 
	: do nothing 
	;;
* ) 
	eval "$(pyenv init -)" 
	eval "$(pyenv virtualenv-init -)"
	;;
esac

# }}}

# 
# USER VARIABLES {{{
#
export CODE="${HOME}/Code/aghast"

df() {
	cd "${DOTFILES}/${*:-}"
}

wo() {
	# Just fail.
	[ $# -eq 0 ] && return 1

	local target="${CODE}/${*}"

	if [ -d "$target" ]
	then
		cd "$target"
		return
	fi

	# Abbreviation. Try to figure out if there's a valid longer match.
	case "$target" in
	*-* )	endword="${*#*-}" ;;
	* )	endword="${*}" ;;
	esac

	n_matches=0
	for cand in "${CODE}"/*-"$endword"
	do
		if [ -d "$cand" ]
		then
			n_matches=$(($n_matches + 1))
			target="$cand"
		fi
	done

	case "$n_matches" in
	0 ) 	printf "No such directory '$target' in %s" \
			"CODE, and nothing similar\n"
		return 1
		;;
	1 )	cd "$target"
		;;
	* )	printf "Multiple candidates found:\n"
		for cand in "${CODE}"/*-"$endword"
		do
			printf "  *  %s\n" "$cand"
		done
		return 0
		;;
	esac
}
# }}}
