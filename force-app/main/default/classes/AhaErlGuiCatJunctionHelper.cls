/**
 * @description Trigger helper for AHA_ERL_Category_Guidance_Junction__c. Assigns a unique
 * ExternalIdentifier__c to newly inserted junction records that do not yet have one.
 */
public with sharing class AhaErlGuiCatJunctionHelper {
    /**
     * @description Sets ExternalIdentifier__c on junctions in the given Id set that are
     * currently null, using the format 'AHAERLGCJ-{Id}'.
     * @param junctionids Ids of the newly inserted AHA_ERL_Category_Guidance_Junction__c records
     */
    public static void updateExternalIdentifier(Set<Id> junctionids) {
        List<AHA_ERL_Category_Guidance_Junction__c> junctionsToUpdate = [SELECT Id, ExternalIdentifier__c FROM AHA_ERL_Category_Guidance_Junction__c WHERE Id IN :junctionids AND ExternalIdentifier__c = null];
        if (!junctionsToUpdate.isEmpty()) {
            for (AHA_ERL_Category_Guidance_Junction__c junction : junctionsToUpdate) {
                junction.ExternalIdentifier__c = 'AHAERLGCJ-' + junction.Id;
            }
            update junctionsToUpdate;
        }
    }
}