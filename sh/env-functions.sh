# $DOTFILES/sh/env-functions.sh
#
# Functions for manipulating PATH & similar variables.

# This should never happen. Seriously.
if [ "X$PATH" = "X" ]
then 
	printf "\n\nPATH was empty in " >&2
	PATH=/usr/local/bin:/usr/bin:/bin:/path-was-empty-in-envfunctions
fi

# Check for test mode.
if [ "$1" = "-t" -o "$1" = "--test" ]
then
	_path_run_tests=true	# Set to true to run self-tests
fi

try_source() {
	if [ $# -ne 1 ]
	then
		cat >&2 <<-USAGE
Usage: try_source FILE

		USAGE
		return 1
	fi

	local srcfile="$1"
	. "$srcfile"
}

:<<='cut'

=item B<path_add> [ --after [DIR] | --before [DIR] ] ITEM PATH

When trying to integrate a package with a user's environment, frequently
adding to a Unix path-variable is necessary. Typically, a new package will
have one or more executable directories to add to PATH, possibly some man
pages to add to MANPATH, etc.

B<path_add> supports adding a single directory to a path, optionally allowing
a specification of where it is to be located. The result is printed to stdout,
for capture in the path variable again:

    PATH="$(path_add '/new_dir' "$PATH")"

=cut

_path_error() {
	printf "%s ERROR: %s\n" "${FUNCNAME[1]}" "$*" >&2
}

_path_warning() {
	printf "%s WARNING: %s\n" "${FUNCNAME[1]}" "$*" >&2
}

path_add() {
	local position="--after"
	local target

	while [ $# -gt 2 ]
	do
		case "$1" in 
		--after|--before)
			position="$1"
			shift

			if [ "$#" -gt 2 -a "$1" != -- ]
			then
				target="$1" 
				shift 
			fi
			;;
		--)	shift; break ;;
		*)	break ;;
		esac
	done
	
	if [ "$#" -ne 2 ]
	then
		if [ "$#" -lt 2 ]
		then
			_path_error 'You must provide both DIR and $PATHVAR'
		else
			_path_error 'Too many arguments!'
		fi

		cat >&2 <<-'USAGE'

Usage: PATHVAR=$(path_add [ { --before | --after } [DIR] ] "DIR" "$PATHVAR")

		USAGE
		return 1
	fi

	local item="$1"
	local path="$2"

	expr "$item" : ".*[[:cntrl:]]" >/dev/null \
		&& _path_warning "Control characters in ${item@A}"
	expr "$path" : ".*[[:cntrl:]]" >/dev/null \
		&& _path_warning "Control characters in '${path@A}"

	if [ -n "$target" ] && expr ":${path}:" :  ".*:$target:" >/dev/null
	then
		path=:"$path":

		if [ "$position" = --after ]
		then
			local t_start="${path%:"$target":*}:$target"
			local t_end="${path##*:"$target":}"
		else 
			local t_start="${path%%:"$target":*}"
			local t_end="$target:${path#*:"$target":}"
		fi

		path="${t_start:+"${t_start#:}:"}$item${t_end:+":${t_end%:}"}"
	else
		# Target wasn't specified, or is missing from path

		if [ "$position" = --after ]
		then
			path="$path:$item"
		else
			path="$item:$path"
		fi
	fi

	printf "%s\n" "$path"
	return 0
}

path_delete() {
	local target="$1"
	local path=":$2:"
	path="${path//:$target}"
	path="${path#:}"
	path="${path%:}"
	printf "%s\n" "${path}"
	return 0
}

_test_path_add() {
	local save_path=$PATH
	local path
	local varvar="$*"
	local but_var

	if [ -n $varvar ]
	then
		but_var=" but $varvar"
	fi

	## Tests with no args
	
	path=$(path_add 2>/dev/null)
	nok $? Should fail with no args.

	path_add 2>&1 | grep -q 'Usage:'
	ok $? Should print a usage message with no args$but_var.

	diag Tests with empty PATH -- 0path
	
	local _0path=''

	path=$(path_add "/opt" "$_0path")
	is "$path" ":/opt" Default  works with empty path -- 0path

	path=$(path_add --after /opt "$_0path")
	is "$path" ":/opt" Works with  -a [no arg] -- 0path

	path=$(path_add --after /x /opt "$_0path")
	is "$path" ":/opt" Works with  [bogus] --after /x -- 0path

	path=$(path_add --before /opt "$_0path")
	is "$path" "/opt:" Works with  --before [no arg] -- 0path
	
	path=$(path_add --before /x /opt "$_0path")
	is "$path" "/opt:" Works with  [bogus] --before /x -- 0path
	
	unset _0path

	diag Tests with 1 directory in path - 1path
	
	local _1path=/bin

	path=$(path_add /opt "$_1path")
	is "$path" "/bin:/opt" Default  is to append -- 1path

	path=$(path_add  --after /opt "$_1path")
	is "$path" "/bin:/opt" Appends with  --after [no arg] -- 1path

	path=$(path_add  --after /bin /opt "$_1path")
	is "$path" "/bin:/opt" Appends with  --after /bin -- 1path

	path=$(path_add  --after /x /opt "$_1path")
	is "$path" "/bin:/opt" Appends with  [bogus] --after /x -- 1path

	path=$(path_add  --before /opt "$_1path")
	is "$path" "/opt:/bin" Inserts with  --before [no arg] -- 1path
	
	path=$(path_add  --before /bin /opt "$_1path")
	is "$path" "/opt:/bin" Inserts with  --before /bin -- 1path

	path=$(path_add  --before /x /opt "$_1path")
	is "$path" "/opt:/bin" Inserts with  [bogus] --before /x -- 1path
	
	unset _1path
	

	diag Tests with 2 directories in path - 2path
	
	local _2path=/usr/bin:/bin

	path=$(path_add /opt "$_2path")
	is "$path" "/usr/bin:/bin:/opt" Default is to append -- 2path

	path=$(path_add --after /opt "$_2path")
	is "$path" "/usr/bin:/bin:/opt" Appends with  --after [no arg] -- 2path

	path=$(path_add --after /bin /opt "$_2path")
	is "$path" "/usr/bin:/bin:/opt" Appends with  --after /bin -- 2path

	path=$(path_add --after /usr/bin /opt "$_2path")
	is "$path" "/usr/bin:/opt:/bin" Appends inside with --after /usr/bin -- 2path

	path=$(path_add --after /x /opt "$_2path")
	is "$path" "/usr/bin:/bin:/opt" Appends with [bogus] --after /x -- 2path

	path=$(path_add --before /opt "$_2path")
	is "$path" "/opt:/usr/bin:/bin" Prepends with --before [no arg] -- 2path
	
	path=$(path_add --before /usr/bin /opt "$_2path")
	is "$path" "/opt:/usr/bin:/bin" Inserts with --before /usr/bin -- 2path

	path=$(path_add --before /bin /opt "$_2path")
	is "$path" "/usr/bin:/opt:/bin" Inserts inside with --before /bin -- 2path

	path=$(path_add --before /x /opt "$_2path")
	is "$path" "/opt:/usr/bin:/bin" Prepends with [bogus] --before /x -- 2path
	
	unset _2path

	diag Tests with 3 directories in path - 3path
	
	local _3path=/sbin:/usr/bin:/bin

	path=$(path_add /opt "$_3path")
	is "$path" "/sbin:/usr/bin:/bin:/opt" Default is to append -- 3path

	path=$(path_add --after /opt "$_3path")
	is "$path" "/sbin:/usr/bin:/bin:/opt" Appends with --after [no arg] -- 3path

	path=$(path_add --after /bin /opt "$_3path")
	is "$path" "/sbin:/usr/bin:/bin:/opt" Appends with --after /bin -- 3path

	path=$(path_add --after /usr/bin /opt "$_3path")
	is "$path" "/sbin:/usr/bin:/opt:/bin" Inserts after with --after /usr/bin -- 3path

	path=$(path_add --after /sbin /opt "$_3path")
	is "$path" "/sbin:/opt:/usr/bin:/bin" Inserts after with --after /sbin -- 3path

	path=$(path_add --after /x /opt "$_3path")
	is "$path" "/sbin:/usr/bin:/bin:/opt" Appends with [bogus] --after /x -- 3path

	path=$(path_add --before /opt "$_3path")
	is "$path" "/opt:/sbin:/usr/bin:/bin" Prepends with --before [no arg] -- 3path
	
	path=$(path_add --before /usr/bin /opt "$_3path")
	is "$path" "/sbin:/opt:/usr/bin:/bin" Inserts before with --before /usr/bin -- 3path

	path=$(path_add --before /bin /opt "$_3path")
	is "$path" "/sbin:/usr/bin:/opt:/bin" Inserts before with --before /bin -- 3path

	path=$(path_add --before /x /opt "$_3path")
	is "$path" "/opt:/sbin:/usr/bin:/bin" Prepends with [bogus] --before /x -- 3path
	
	unset _3path

}

_path_maybe_run_tests() {
	case $_path_run_tests in 
	true) : okay. ;;
	* ) _path_run_tests=false ;;
	esac

	if ! $_path_run_tests
	then
		return 0
	fi

	. tap.sh --no-prefix || {
		_path_error "Unable to load tap.sh testing functions"
		return 1
	}

	_test_path_add
}

dont_exit() {
	printf "I want to exit, but I won't\n"
}

trap dont_exit EXIT

_path_maybe_run_tests
unset -f \
	_path_maybe_run_tests \
	_test_path_add \

unset -v \
	_path_run_tests
