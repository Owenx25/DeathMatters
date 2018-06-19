Scriptname DM_PresetDifficultyChangeScript extends Terminal
String Property option const auto mandatory
CustomEvent Preset_DM
CustomEvent Preset_DL
CustomEvent Preset_RI
Event OnMenuItemRun(int auiMenuItemID, ObjectReference akTerminalRef)
	Var[] kargs = new Var[1]
	kargs[0] = auiMenuItemID
	if option == "DM"
		SendCustomEvent("Preset_DM", kargs)
	ElseIf option == "DL"
		SendCustomEvent("Preset_DL", kargs)
	ElseIf option == "RI"
		SendCustomEvent("Preset_RI", kargs)
	endif
	trace(self, "Sent PresetChange with selectionIndex " + kargs[0])
endEvent

bool Function Trace(ScriptObject CallingObject, string asTextToPrint, int aiSeverity = 0) DebugOnly
	;we are sending callingObject so we can in the future route traces to different logs based on who is calling the function
	string logName = "DeathMatters"
	debug.OpenUserLog(logName) 
	RETURN debug.TraceUser(logName, CallingObject + ": " + asTextToPrint, aiSeverity)
EndFunction