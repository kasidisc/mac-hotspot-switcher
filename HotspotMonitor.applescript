-- Trigger app to watch — change this to any app name (e.g. Zoom, FaceTime, Discord)
property triggerApp : "TeamViewer"

property wasAppRunning : false
property switchAttempted : false

on run
	set wasAppRunning to false
	set switchAttempted to false
end run

on idle
	set appCheck to do shell script "pgrep -x " & triggerApp & " > /dev/null 2>&1 && echo yes || echo no"
	set appRunning to appCheck is "yes"

	if appRunning and not wasAppRunning then
		set switchAttempted to false
	end if
	set wasAppRunning to appRunning

	if appRunning and not switchAttempted then
		set result to do shell script "swift /usr/local/bin/connect_hotspot.swift 2>&1"

		if result starts with "ALREADY_CONNECTED" or result starts with "CONNECTED" then
			set switchAttempted to true
			if result starts with "CONNECTED" then
				do shell script "osascript -e 'display notification \"Switched to iPhone hotspot\" with title \"Hotspot Connected\" sound name \"Glass\"' &"
			end if
		else if result starts with "NOT_VISIBLE" then
			do shell script "osascript -e 'display notification \"Turn on Personal Hotspot on your iPhone\" with title \"Hotspot Required\" sound name \"Ping\"' &"
			do shell script "afplay /System/Library/Sounds/Ping.aiff &"
		end if
	end if

	return 5
end idle
