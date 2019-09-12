# NOTE: The `local` keyword is not part of the POSIX standard. But all the
# shells I've used in the past 10 years or so have supported it, so I'm going
# to leave it in. You can simply delete the keyword if you ever have a problem
# with it. (Or stop running in strict-POSIX mode, you git!)

if [ -z "$DOTFILES" ]
then
	printf "ERROR: The DOTFILES environment variable is not set.\n" >&2
	printf "Set this variable to the path to the dotfiles project.\n\n" >&2
	exit 1
fi

# This is mainly "deploy with symbolic links".
deploy_linux() {
	local source="$DOTFILES/bash"
	local target="$HOME"

	ln -s "$source/bashrc" "$target/.bashrc" 
	ln -s "$source/bashrc.d" "$target/.bashrc.d" 

	ln -s "$source/bash_profile" "$target/.bash_profile" 
	ln -s "$source/bash_profile.d" "$target/.bash_profile.d" 
}

make_stub() {
	local source="$1"
	local target="$2"

	source="$(echo "$source" \
		| sed -e "s,$DOTFILES,\${DOTFILES:-$DOTFILES}," -e 's,/./,/,g')"
	cat > "$target" <<-EOF
		# stub file in lieu of symbolic links
		. "$source"
	EOF
}

copy_files_as_stubs() {
	local source="$1"
	local target="$2"

	(
		cd "$source";
		find . \( ! -regex '\.' \) -type d \
			-exec mkdir "$target"/{} \;
		find . -type f \
		| while read scriptpath 
		  do
			  make_stub "$source/$scriptpath" "$target/$scriptpath" 
		  done
	)
}

# This is mainly "deploy with no symbolic links".
deploy_windows() {
	local source="$DOTFILES/bash"
	local target="$HOME"

	make_stub "$source/bashrc" "$target/_bashrc"
	mkdir -p "$target/_bashrc.d"
	copy_files_as_stubs "$source/bashrc.d" "$target/_bashrc.d"

	make_stub "$source/bash_profile" "$target/_bash_profile"
	mkdir -p "$target/_bash_profile.d"
	copy_files_as_stubs "$source/bash_profile.d" "$target/_bash_profile.d"
}

case "$(uname -s)" in
Linux|*BSD)
	deploy_linux
	;;
CYGWIN_NT*)  # cygwin
	deploy_windows
	;;
Interix)     # Windows Services for Unix
	deploy_windows
	;;
Windows_NT)  # busybox-w32
	deploy_windows
	;;
MS-DOS)      # djgpp
	printf "ERROR: Don't know how to deploy to MS-DOS (yet)!\n\n" >&2
	false
	;;
GNU*)        # Debian GNU/HURD
	printf "ERROR: Don't know how to deploy on HURD (yet)!\n\n" >&2
	false
	;;
*)
	printf "ERROR: Don't know how to deploy on $(uname -s) (yet)!\n\n" >&2
	false
	;;
esac

