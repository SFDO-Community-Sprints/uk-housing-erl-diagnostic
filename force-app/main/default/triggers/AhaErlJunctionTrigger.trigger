trigger AhaErlJunctionTrigger on AHA_ERL_Junction__c (after insert) {
    AhaErlJunctionHelper.updateExternalIdentifier(Trigger.newMap.keySet());
}