#!/bin/bash

REMOTE="$1"
while [[ -z "$REMOTE" ]]; do
	read -p "Remote ([user@]host:[path]): " REMOTE
done

LOCAL="$2"
if [[ -z "$LOCAL" ]]; then
	RUSERHOST="${REMOTE%:*}"
	RPATH="${REMOTE##*:}"
	RUSER="${RUSERHOST%@*}"
	RHOST="${RUSERHOST##*@}"

	[[ "$RUSER" = "$RUSERHOST" ]] && RUSER=""

	if [[ -z "$RPATH" ]]; then
		RPATH_DISPLAY="home"
		[[ -n "$RUSER" ]] && RPATH_DISPLAY="$RUSER $RPATH_DISPLAY"
	else
		RPATH_DISPLAY="${RPATH//\//-}"
		[[ ${RPATH_DISPLAY:0:1} = '-' ]] && RPATH_DISPLAY="${RPATH_DISPLAY:1}"
	fi

	RHOST_DISPLAY="${RHOST%%.*}"

	if [[ -z "$RPATH_DISPLAY" ]]; then
		LOCAL_DISPLAY="$RHOST_DISPLAY"
	else
		LOCAL_DISPLAY="$RPATH_DISPLAY @ $RHOST_DISPLAY"
	fi
	LOCAL="/Volumes/$RPATH_DISPLAY @ $RHOST_DISPLAY"
else
	LOCAL_DISPLAY="${LOCAL##*/}"
fi


i=1
LOCAL_MNT="$LOCAL"
while [[ -e "$LOCAL_MNT" ]]; do
	LOCAL_MNT="$LOCAL $i"
	(( i++ ))
done

# echo "REMOTE = $REMOTE"
# echo "RPATH_DISPLAY = $RPATH_DISPLAY"
# echo "RHOST_DISPLAY = $RHOST_DISPLAY"
# echo "LOCAL = $LOCAL"
# echo "LOCAL_MNT = $LOCAL_MNT"
mkdir "$LOCAL_MNT" || exit $?

sshfs -o "volname=$LOCAL_DISPLAY" "$REMOTE" "$LOCAL_MNT"
