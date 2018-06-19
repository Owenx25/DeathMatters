ScriptName DM_QuestScript Extends Quest 

workshopscript SanctuaryRef
Actor Property PlayerRef Auto Mandatory
Holotape Property DM_Holotape Auto const Mandatory
Message Property DM_StartMessage Auto const Mandatory
Message Property DM_EarlyMessage Auto const Mandatory
FormList Property DM_StartWorkshopList Auto const Mandatory

; Eventual TODO
; - Put in some logic for respawn markers at story tied settlements like Boston Airport, The Castle, and any others
; - Mess with changing players face with F4SE
; - Put in logic for Far Harbor DLC, need to warn player on mod page
; - Give outfits their own weapons

Event OnQuestInit()
	trace(self, "Death Matters Quest Initialized")
	int index = DM_StartWorkshopList.GetSize() - 1
	bool break = false
	while index
		; Check if player owns any settlements at startup
		ObjectReference settlementObj = DM_StartWorkshopList.GetAt(index) as ObjectReference
		workshopscript settlement = settlementObj as workshopscript 
		if settlement.OwnedbyPlayer && !break
			trace(self, "Player owns settlement on QuestInit pass")
			DM_StartMessage.Show()
			if PlayerRef.GetItemCount(DM_Holotape) == 0
				PlayerRef.AddItem(DM_Holotape, 1)
			EndIf
			PlayerRef.SetEssential(true)
			break = true
		EndIf
		; If we found a settlement we can fast-foward to the end of the loop
		if break
			index = 0
		else
			index -= 1
		endif
	endWhile
	if !break
		trace(self, "No settlement found on QuestInit pass")
		DM_EarlyMessage.Show()
	endif
EndEvent

; I took this from one of the vanilla scripts, Very useful!
bool Function Trace(ScriptObject CallingObject, string asTextToPrint, int aiSeverity = 0) Global DebugOnly
	;we are sending callingObject so we can in the future route traces to different logs based on who is calling the function
	string logName = "DeathMatters"
	debug.OpenUserLog(logName) 
	RETURN debug.TraceUser(logName, CallingObject + ": " + asTextToPrint, aiSeverity)
EndFunction
