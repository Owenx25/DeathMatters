ScriptName DM_QuestScript Extends Quest 

workshopscript SanctuaryRef
Actor Property PlayerRef Auto Mandatory
Holotape Property DM_Holotape Auto const Mandatory
Keyword Property DM_EnabledKeyword Auto const Mandatory
Keyword Property DM_DisabledKeyword Auto const Mandatory
Message Property DM_StartMessage Auto const Mandatory
Message Property DM_EarlyMessage Auto const Mandatory

; Eventual TODO
; - Put in some logic for respawn markers at story tied settlements like Boston Airport, The Castle, and any others
; - Mess with changing players face with F4SE
; - Put in logic for Far Harbor DLC, need to warn player on mod page

Event OnQuestInit()
	trace(self, "Death Matters Quest Initialized")
	ObjectReference SanctuaryID = Game.GetForm(0x000250FE) as ObjectReference ;Sanctuary 27
	; Mod shouldn't start until player gets sanctuary as a settlement
	SanctuaryRef = SanctuaryID as workshopscript
	if SanctuaryRef
		if SanctuaryRef.OwnedbyPlayer
			trace(self, "Player owns sanctuary on QuestInit pass")
			; startup death matters
			PlayerRef.AddKeyword(DM_EnabledKeyword)
			DM_StartMessage.Show()
			if (PlayerRef.GetItemCount(DM_Holotape) == 0)
				PlayerRef.AddItem(DM_Holotape, 1)
			endif
			PlayerRef.SetEssential(true)
		else
			trace(self, "No sanctuary on QuestInit pass")
			DM_EarlyMessage.Show()
			PlayerRef.AddKeyword(DM_DisabledKeyword)
		endif
	endif
EndEvent

; I took this from one of the vanilla scripts, Very useful!
bool Function Trace(ScriptObject CallingObject, string asTextToPrint, int aiSeverity = 0) Global DebugOnly
	;we are sending callingObject so we can in the future route traces to different logs based on who is calling the function
	string logName = "DeathMatters"
	debug.OpenUserLog(logName) 
	RETURN debug.TraceUser(logName, CallingObject + ": " + asTextToPrint, aiSeverity)
EndFunction
