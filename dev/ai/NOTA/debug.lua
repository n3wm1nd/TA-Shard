DebugEnabled = 1

function EchoDebug(inStr)
	if DebugEnabled then
		game:SendToConsole(inStr)
	end
end
