Scriptname DM_DeathMarkerAliasScript extends ReferenceAlias

Actor property PlayerRef Auto const mandatory
Quest property DM_RecoveryQuest Auto const mandatory

Event OnTriggerEnter(ObjectReference akActionRef)
	if (akActionRef == PlayerRef)
		DM_RecoveryQuest.SetStage(20)
		DM_RecoveryQuest.Stop()
	endif
EndEvent