@IsTest
private class ContractManagerTest{
    private static final String BASEURI = 'https://brave-otter-3m0fxb-dev-ed.my.salesforce.com/services/apexrest/Contracts/';
    @isTest
    static void testCreateContract(){
        // Call the method to test
        Id accId = createAccount();
        Id thisContractId = ContractManagerService.createContract(accId, '20/10/2023', '12');
        // Verify results
        System.assert(thisContractId != null);
        Contract thisContract = [SELECT Id
                               FROM Contract
                               WHERE Id = :thisContractId];
        System.assert(thisContract != null);
    }


    @isTest
    static void testCreateContractWithErrors(){
        // Call the method to test
        Id accId = createAccount();
        Id thisContractId = ContractManagerService.createContract(accId+'1', '20/10/2023', '12');
        // Verify results
        System.assert(thisContractId == null);
    }
    @isTest
    static void testUpdateContractFields(){
        Id recordId = createTestRecord();
        RestRequest request = new RestRequest();
        request.requestUri = BASEURI + recordId;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"Status": "activated","Description": "This is a test","ContractTerm": "24","StartDate": "20/10/2021","ActivatedDate": "2018-08-31T06:00:00.000Z"}');
        RestContext.request = request;
        // Update email of existing record 
        ContractManagerService.updateContractFields();
        // Verify record was updated
        String recordStatus = [SELECT Status
                               FROM Contract
                               WHERE Id = :recordId LIMIT 1].Status;
        System.assert(recordStatus != null);
        System.assertEquals(recordStatus, 'Activated','Status is different');
    }

    @isTest
    static void testUpdateContractFieldsWithError(){
        Id recordId = createTestRecord();
        RestRequest request = new RestRequest();
        request.requestUri = BASEURI + recordId;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"Status": "activationated"}');
        RestContext.request = request;
        // Update email of existing record 
        ContractManagerService.updateContractFields();
        // Verify record was updated
        String recordStatus = [SELECT Status
                               FROM Contract
                               WHERE Id = :recordId LIMIT 1].Status;
        System.assert(recordStatus != null);
        System.assertEquals(recordStatus, 'Draft','Status is different');
    }
    // Helper method
    static Id createTestRecord(){
        // Create test record
        Contract ContractTest = new Contract(AccountId = createAccount(),startDate = Date.parse('20/10/2020'), ContractTerm = 60);
        insert ContractTest;
        return ContractTest.Id;
    }

    static Id createAccount(){
        // Create test record
        Account AccountTest = new Account(Name = 'Saul Goodman', BillingStreet = '123 Main Street', BillingCity = 'New York', BillingState = 'NY', BillingPostalCode = '10001', BillingCountry = 'USA');
        insert AccountTest;
        return AccountTest.Id;
    }

}