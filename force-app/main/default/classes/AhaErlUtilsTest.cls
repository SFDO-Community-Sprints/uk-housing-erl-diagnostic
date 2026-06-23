@isTest
private class AhaErlUtilsTest {

    /**
     * @description Tests that isSandbox() returns a boolean without throwing an exception.
     * The actual return value depends on the org type (sandbox/scratch vs production).
     */
    @isTest
    static void testIsSandboxReturnsBoolean() {
        Boolean result = AhaErlUtils.isSandbox();
        System.assertNotEquals(null, result, 'isSandbox() should return a boolean value, not null');
    }

    /**
     * @description Tests that isSandbox() correctly identifies sandbox/scratch orgs.
     * In a sandbox or scratch org test context, this should return true.
     */
    @isTest
    static void testIsSandboxInTestOrg() {
        // When run in a test context (which is always a sandbox or scratch org),
        // the domain URL will contain .sandbox. or .scratch.
        Boolean result = AhaErlUtils.isSandbox();
        System.assertEquals(true, result, 'isSandbox() should return true when running in a sandbox or scratch org');
    }

    /**
     * @description Tests that hasErlAdministrationPermission() returns a boolean.
     * Does not assume the result value since permissions depend on user setup.
     */
    @isTest
    static void testHasErlAdministrationPermissionReturnsBoolean() {
        Boolean result = AhaErlUtils.hasErlAdministrationPermission();
        System.assertNotEquals(null, result, 'hasErlAdministrationPermission() should return a boolean value, not null');
    }

}
