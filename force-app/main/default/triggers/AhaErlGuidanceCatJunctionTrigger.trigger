trigger AhaErlGuidanceCatJunctionTrigger on AHA_ERL_Category_Guidance_Junction__c (after insert) {
    AhaErlGuiCatJunctionHelper.updateExternalIdentifier(Trigger.newMap.keySet());
}