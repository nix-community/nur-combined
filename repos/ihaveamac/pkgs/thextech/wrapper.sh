#!NIXBASH

# based on "thextech-smbx" taken from:
# https://wohlsoft.ru/projects/TheXTech/_downloads/releases/thextech-game-smbx-1.3-v1.3.7.3.deb

if [[ -z "$XDG_DATA_HOME" ]]; then
    XDG_DATA_HOME="$HOME/.local/share";
fi

#PACK_ID=smbx
#GAME_DIR="smbx13"
#GAME_NAME="Super Mario Bros. X"
#
#OLD_PATH="$HOME/.thextech-$PACK_ID"
#NEW_PATH="$XDG_DATA_HOME/TheXTech"

PACK_ID="NIXPACKID"
GAME_DIR="NIXGAMEDIR"
GAME_NAME="NIXGAMENAME"

OLD_PATH="$HOME/.thextech-$NIXPACKID"
NEW_PATH="$XDG_DATA_HOME/TheXTech"


function check_pack_exists_at()
{
    if [[ -e "$1/battle/$PACK_ID" \
       || -e "$1/gameplay-records/$PACK_ID" \
       || -e "$1/gif-recordings/$PACK_ID" \
       || -e "$1/screenshots/$PACK_ID" \
       || -e "$1/worlds/$PACK_ID" \
       || -e "$1/settings/gamesaves/$PACK_ID" ]] ; then
        return 1;
    else
        return 0;
    fi
}

function check_pack_exists_modern()
{
    if (check_pack_exists_at "$NEW_PATH") || (check_pack_exists_at "$HOME/.PGE_Project/thextech"); then
        return 1;
    fi

    return 0;
}

function check_pack_exists_legacy()
{
    if [[ -d "$OLD_PATH/battle" \
       || -d "$OLD_PATH/gameplay-records" \
       || -d "$OLD_PATH/gif-recordings" \
       || -d "$OLD_PATH/screenshots" \
       || -d "$OLD_PATH/worlds" \
       || -d "$OLD_PATH/settings/gamesaves" ]] ; then
        return 0;
    fi

    return 1
}

function succ()
{
    echo "SUCC"
    HAS_SUCCESS="$HAS_SUCCESS $1"
    return 0;
}

function fail()
{
    echo "FAIL"
    HAS_FAILURE="$HAS_FAILURE $1"
    return 1;
}

function migrate_folder()
{
    if [[ ! -d "$OLD_PATH/$1" ]] ; then
        return 0;
    fi

    if mkdir -p "$NEW_PATH/$1" \
       && mv -nT "$OLD_PATH/$1" "$NEW_PATH/$1/$PACK_ID" \
       && ln -s "$NEW_PATH/$1/$PACK_ID" "$OLD_PATH/$1"; then
        HAS_SUCCESS="$HAS_SUCCESS $1"
        return 0;
    else
        HAS_FAILURE="$HAS_FAILURE $1"
        return 1;
    fi
}

function migrate_settings()
{
    if [[ ! -f "$OLD_PATH/$1"  ]] ; then
        return 0;
    fi

    if [[ ! -d "$NEW_PATH/settings" ]]; then
        if mkdir -p "$NEW_PATH/settings" ; then
            HAS_FAILURE="$HAS_FAILURE settings"
            return 1;
        fi
    fi

    if [[ ! -f "$NEW_PATH/$1" ]] ; then
        if ! mv "$OLD_PATH/$1" "$NEW_PATH/$1" ; then
            echo "-- Failed to move $1 (mv returned status $?)"
            HAS_FAILURE="$HAS_FAILURE $1"
            return 1;
        fi

        if ! ln -s "$NEW_PATH/$1" "$OLD_PATH/$1" ; then
            echo "-- Failed to create symbolic link for $1 (ln returned status $?)"
            HAS_FAILURE="$HAS_FAILURE $1"
            return 1;
        fi

        HAS_SUCCESS="$HAS_SUCCESS $1"
    fi

    return 0;
}

if ( ! check_pack_exists_modern ) \
  && check_pack_exists_legacy ; then
    migrate_folder "battle" && \
    migrate_folder "gameplay-records" && \
    migrate_folder "gif-recordings" && \
    migrate_folder "screenshots" && \
    migrate_folder "worlds" && \
    migrate_folder "settings/gamesaves" && \
    migrate_settings "settings/thextech.ini" && \
    migrate_settings "settings/controls.ini"
fi

if [[ ! -z "$HAS_SUCCESS" ]] ; then
    zenity --info --text="These TheXTech data folders and settings files for the game \"${GAME_NAME}\" (${PACK_ID}) have been moved from $OLD_PATH to $NEW_PATH: $HAS_SUCCESS.";
fi

if [[ ! -z "$HAS_FAILURE" ]] ; then
    zenity --error --text="These TheXTech data folders and settings files for the game \"${GAME_NAME}\" (${PACK_ID}) could not be fully moved from $OLD_PATH to $NEW_PATH: $HAS_FAILURE. Please manually merge the folders in $OLD_PATH with the $PACK_ID subfolders of the folders in $NEW_PATH.";
fi

NIXBINARYPATH -c ${GAME_DIR} "$@"
