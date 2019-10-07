# $DOTFILES/sh/env.sh
#
# Bedrock environment-setup script for ALL BOURNE SHELLS. All of the various
# $SHRC_SHELL_FLAVOR/* files source this script.
#

# Load core environment functions.
. "$DOTFILES/sh/env-functions.sh"

#
# XDG VARIABLES
#
# Configure the various XDG_* variables if they aren't already set. See
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
#
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share/:/usr/share/}"
export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg/}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Note: I don't have a good cross-OS default for this. Maybe something in
# /tmp? So for now, just gripe if the value isn't provided, and move on.
if [ "X${XDG_RUNTIME_DIR-}" = "X" -o ! -d "$XDG_RUNTIME_DIR" ]
then
	printf "FAIL: XDG_RUNTIME_DIR is not set, or is not a directory!\n"
else
	export XDG_RUNTIME_DIR
fi

#
# ENVIRONMENT MODULES
#
if [ -r "${MODULESHOME:-/usr/share/modules}/init/$SHRC_SHELL_FLAVOR" ]
then
	export MODULESHOME="${MODULESHOME:-/usr/share/modules}"
	. "${MODULESHOME}/init/${SHRC_SHELL_FLAVOR}"
fi

#
# USER HOME/BIN DIRECTORIES
#
[ -d "$HOME/.local/bin" ] \
	&& PATH="$(path_add --before "$HOME/.local/bin" "$PATH")"
[ -d "$HOME/bin"        ] \
	&& PATH="$(path_add --before "$HOME/bin" "$PATH")"

#
# PYTHON DEVELOPMENT {{{
#
# Note: There are some things, like pyenv, that are configured here. Other
# things, like command completion, need to go in the $SHRC_SHELL_FLAVOR 
# directory for the particular shell.
#

#
# Pyenv python-version management tool
#
case ":$PATH:" in
*:${HOME}/.pyenv/bin:* ) : do nothing ;;
* )
	PATH="$(path_add --before "${HOME}/.pyenv/bin" "$PATH")"
	;;
esac

# }}}
