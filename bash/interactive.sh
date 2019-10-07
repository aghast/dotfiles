# $DOTFILES/bash/interactive.sh
# vim: set fdm=marker:
#
# Called for all interactive bash shells.
#

#
# 1. Read in the "all-shells" common setup. {{{
#
try_source "$SHRC_SCRIPT_DIR/../sh/interactive.sh"

# Now repair PS1. The standard POSIX shell doesn't support \[ and \] in
# PS1 to indicate "zero-length" sequences (non-printing escape codes). So
# Bash infers the length of the prompt from PS1 without \[ and \] as being
# longer, and therefore interferes with how readline handles line editing.
fixup_prompt() {
	local prompt="$(printf "${PS1}x" \
		| sed -e 's/\('$'\e''\[[0-9;]*m\)/\\[\1\\]/g' \
		      -e 's/\${PWD}/\\w/g' \
		      -e 's/\${HOSTNAME}/\\h/g' -e 's/\${USER}/\\u/g' \
		      -e 's/\$ /\\$ /')"
	PS1="${prompt%?}"	# %? strips off trailing 'x' from printf
}

fixup_prompt

# }}}

#
# 2. BASH SETTINGS. {{{
#
#    Various tunable configuration knobs in the bash shell.
#

# Check the window size after each command and, if necessary, update the values
# of LINES and COLUMNS.
shopt -s checkwinsize

# Append to the history file, don't overwrite it
shopt -s histappend

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=5000

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# Use vi-style line-editing commands, rather than emacs
set -o vi

# }}}

#
# BASH COMMAND COMPLETION {{{
#

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# }}}

#
# PYTHON DEVELOPMENT {{{
#
### COMMAND/SCRIPT ARG COMPLETION
#

# Use this format to register Bash argument completion for individual 
# applications

for APPNAME in pipx 
do
	eval "$(register-python-argcomplete $APPNAME)"
done

# }}}

#
# DIRENV HOOKS {{{
# 
#    Install the direnv hooks to enable per-project environment files
#    (in $PROJECT_ROOT/.envrc, and children)
#
eval "$(direnv hook bash)"

# }}}

#
# USER SETTINGS {{{
#

# }}}
