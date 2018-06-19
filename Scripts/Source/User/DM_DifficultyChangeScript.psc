Scriptname DM_DifficultyChangeScript extends Terminal
String Property setting const auto mandatory
CustomEvent DC_Respawn
CustomEvent DC_Body
CustomEvent DC_Dismiss
CustomEvent DC_OldBody
CustomEvent DC_Saving
CustomEvent DC_Tracking
Event OnMenuItemRun(int auiMenuItemID, ObjectReference akTerminalRef)
	Var[] kargs = new Var[1]
	kargs[0] = auiMenuItemID
	if setting == "Respawn"
		SendCustomEvent("DC_Respawn", kargs)
	ElseIf setting == "Body"
		SendCustomEvent("DC_Body", kargs)
	ElseIf setting == "Dismiss"
		SendCustomEvent("DC_Dismiss", kargs)
	ElseIf setting == "OldBody"
		SendCustomEvent("DC_OldBody", kargs)
	ElseIf setting == "Saving"
		SendCustomEvent("DC_Saving", kargs)
	ElseIf setting == "Tracking"
		SendCustomEvent("DC_Tracking", kargs)
	endif
	trace(self, "Sent custom event DC_Respawn with selectionIndex " + kargs[0])
endEvent

bool Function Trace(ScriptObject CallingObject, string asTextToPrint, int aiSeverity = 0) DebugOnly
	;we are sending callingObject so we can in the future route traces to different logs based on who is calling the function
	string logName = "DeathMatters"
	debug.OpenUserLog(logName) 
	RETURN debug.TraceUser(logName, CallingObject + ": " + asTextToPrint, aiSeverity)
EndFunction