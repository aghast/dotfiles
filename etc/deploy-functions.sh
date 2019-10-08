#############################################################################
##  Utility functions for use in dotfiles deploy.sh scripts
#############################################################################

H1() {
    printf "\n\n$*\n"
    BULLET=" * "
}

H2() {
    printf "${BULLET}$*\n"
}

ERROR() {
    printf "ERROR: " >&2
    printf "$*\n" >&2
    return 1
}

links_or_copies() {
    case "$(uname -s)" in
    *BSD)        printf "links\n"   ;; # FreeBSD or NetBSD (or ...?)
    Linux)       printf "links\n"   ;; # Linux
    CYGWIN_NT*)  printf "copies\n"  ;; # cygwin
    Interix)     printf "copies\n"  ;; # Windows Services for Unix
    Windows_NT)  printf "copies\n"  ;; # busybox-w32
    MS-DOS)                            # djgpp
        ERROR "Don't know how to deploy to MS-DOS!" 
        return 1
        ;;  
    GNU*)                              # Debian GNU/HURD
        ERROR "Don't know how to deploy on HURD!"
        return 1
        ;;
    *)                                 # "other"
        ERROR "Don't know how to deploy on $(uname -s)!"
        return 1
        ;;
    esac

    return 0
}

require_dotfiles() {
    if [ -z "$DOTFILES" ] || [ ! -d "$DOTFILES" ]
    then
        printf "ERROR: \$DOTFILES is not set, or directory missing." >&2
        return 1
    fi
}


require_file() {
    if [ -f "$1" ]
    then
        : return true
    else
        ERROR "'$1' missing"
    fi
}

symlink() {
    local target="$1"    # Pointed to by link
    local link="$2"        # Link -> target

    if [ -e "$link" ]
    then
        printf "   - Target exists: $link\n"

        if [ -h "$link" ]
        then
            if [ "$target" -ef "$link" ]
            then
                printf "   - ... link already points to $target\n"
                return
            elif rm "$link"
            then
                printf "   - ... removed previous symlink\n"
            else
                ERROR "Could not remove existing symlink"
            fi
        else
            ERROR "File '$link' blocks creation of symlink."
        fi

        if [ $? -ne 0 ]
        then
            return 1
        fi
    fi

    if ln -s "$target" "$link"
    then
        return 0
    else
        ERROR "Failed to link '$link' -> '$target'"
        return 1
    fi
}

# vim: set ts=8 sts=4 sw=4 et:
