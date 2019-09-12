# $DOTFILES/sh/profile.d/XDG_variables.sh
#
# Configure the various XDG_* variables if they aren't already set. See
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

# There is a single base directory relative to which user-specific data files
# should be written. This directory is defined by the environment variable
# $XDG_DATA_HOME.

export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# There is a single base directory relative to which user-specific
# configuration files should be written. This directory is defined by the
# environment variable $XDG_CONFIG_HOME.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# There is a set of preference ordered base directories relative to which data
# files should be searched. This set of directories is defined by the
# environment variable $XDG_DATA_DIRS.

export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share/:/usr/share/}"

# There is a set of preference ordered base directories relative to which
# configuration files should be searched. This set of directories is defined
# by the environment variable $XDG_CONFIG_DIRS.

export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg/}"

# There is a single base directory relative to which user-specific
# non-essential (cached) data should be written. This directory is defined by
# the environment variable $XDG_CACHE_HOME.

export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# There is a single base directory relative to which user-specific
# runtime files and other file objects should be placed. This directory is
# defined by the environment variable $XDG_RUNTIME_DIR.

# Note: I don't have a good cross-OS default for this. Maybe something in
# /tmp? So for now, just gripe if the value isn't provided, and move on.

if [ "X${XDG_RUNTIME_DIR-}" = "X" -o ! -d "$XDG_RUNTIME_DIR" ]; then
	printf "FAIL: XDG_RUNTIME_DIR is not set, or is not a directory!\n"
else
	export XDG_RUNTIME_DIR
fi
