global class AhaErlFlowOutput {
    @AuraEnabled public String userId { get; set; }
    @AuraEnabled public String userName { get; set; }
    @AuraEnabled public String timestamp { get; set; }
    @AuraEnabled public List<AhaErlFlowOutputLine> repairSorLines { get; set; }
}
