trigger AhaErlCategoryJunctionTrigger on AHA_ERL_Category_Junction__c (after insert) {
    AhaErlCategoryJunctionHelper.updateExternalIdentifier(Trigger.newMap.keySet());
}