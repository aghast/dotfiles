source_files_in_dir() {
	for f in "$1"/*
	do
		[[ -r $f ]] && source "$f"
	done
}

