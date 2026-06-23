@isTest
private class AhaErlFlowOutputTest {

    @isTest
    static void testFlowOutputAndLineUsageForCoverage() {
        AhaErlFlowOutputLine line = new AhaErlFlowOutputLine();
        line.outputReference = 'OUT-1';
        line.sorUnit = 'Unit';
        line.sorTrade = 'Trade';
        line.sorCode = 'CODE1';
        line.sorSubject = 'Subject';
        line.sorDescription = 'Description';
        line.sorQuantity = '2';
        line.sorPriority = 'Routine';
        line.sorJobTitle = 'Job Title';
        line.sorHeading = 'Heading';
        line.sorComment = 'Comment';
        line.sorRate = '12.34';
        line.repairLocation = 'KIT - Kitchen';

        AhaErlFlowOutput output = new AhaErlFlowOutput();
        output.userId = UserInfo.getUserId();
        output.userName = 'Test User';
        output.timestamp = String.valueOf(System.now());
        output.repairSorLines = new List<AhaErlFlowOutputLine>{ line };

        System.assertEquals(UserInfo.getUserId(), output.userId, 'userId should be settable');
        System.assertEquals('Test User', output.userName, 'userName should be settable');
        System.assertNotEquals(null, output.timestamp, 'timestamp should be settable');
        System.assertEquals(1, output.repairSorLines.size(), 'repairSorLines should contain one line');
        System.assertEquals('CODE1', output.repairSorLines[0].sorCode, 'nested line properties should be settable');

        String jsonBody = JSON.serialize(output);
        AhaErlFlowOutput roundTripped = (AhaErlFlowOutput) JSON.deserialize(jsonBody, AhaErlFlowOutput.class);

        System.assertEquals('Test User', roundTripped.userName, 'serialized output should deserialize correctly');
        System.assertEquals(1, roundTripped.repairSorLines.size(), 'serialized nested list should deserialize correctly');
        System.assertEquals('CODE1', roundTripped.repairSorLines[0].sorCode, 'line data should survive serialize/deserialize');
    }
}
