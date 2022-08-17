@IsTest
private class ContactManagerTest{
    private static final String BASEURI = 'https://brave-otter-3m0fxb-dev-ed.my.salesforce.com/services/apexrest/Contacts/';
    @isTest
    static void testCreateContact(){
        // Call the method to test
        ID thisContactId = ContactManagerService.createContact('Luke', 'Skywalker', 'greensaber@jedi.com');
        // Verify results
        System.assert(thisContactId != null);
        Contact thisContact = [SELECT Id, Email
                               FROM Contact
                               WHERE Id = :thisContactId];
        System.assert(thisContact != null);
        System.assertEquals(thisContact.Email, 'greensaber@jedi.com', 'Email is different');
    }

    @isTest
    static void testCreateContactAlreadyExists (){
        // Call the method to test
        createTestRecord();
        ContactManagerService.createContact('Dare', 'Devil', 'switftjustice@liberty.com');
        // Verify results
        Contact[] thisContact = [SELECT Id, FirstName,LastName
                               FROM Contact
                               WHERE Email = 'switftjustice@liberty.com'];
        System.assert(thisContact.size() == 1);
        // Verify name is Saul Goodman
        System.assertEquals(thisContact[0].FirstName, 'Saul', 'First name is different');
        System.assertEquals(thisContact[0].LastName, 'Goodman', 'First name is different');
    }

    @isTest
    static void testCreateContactWithError (){
        // Call the method to test
        Id recordId = ContactManagerService.createContact('Dare', 'Devil', 'switftjustice@libert@y.com');
        // Verify results
        Contact[] thisContact = [SELECT Id
                               FROM Contact
                               WHERE Id =:recordId];
        System.assert(thisContact.isEmpty());
    }

    


    @isTest
    static void testDeleteContact(){
        Id recordId = createTestRecord();
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri = BASEURI + recordId;
        request.httpMethod = 'DELETE';
        RestContext.request = request;
        // Call the method to test
        ContactManagerService.deleteContact();
        // Verify record is deleted
        Boolean isActive = [SELECT IsActive__c
                            FROM Contact
                            WHERE Id = :recordId
                            LIMIT 1].IsActive__c;
        System.assert(!isActive, 'Contact is not inactive');
    }

    @isTest
    static void testDeleteContactWithError(){
        Id recordId = createTestRecord();
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri = BASEURI + recordId+'1';
        request.httpMethod = 'DELETE';
        RestContext.request = request;
        // Call the method to test
        ContactManagerService.deleteContact();
        // Verify record is deleted
        Boolean isActive = [SELECT IsActive__c
                            FROM Contact
                            WHERE Id = :recordId
                            LIMIT 1].IsActive__c;
        System.assert(isActive, 'Contact is inactive');
    }

    

    @isTest
    static void testUpdateContactFields(){
        Id recordId = createTestRecord();
        RestRequest request = new RestRequest();
        request.requestUri = BASEURI + recordId;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"email": "attorney@law.com"}');
        RestContext.request = request;
        // Update email of existing record 
        ContactManagerService.updateContactFields();
        // Verify record was updated
        String emailString = [SELECT Email
                               FROM Contact
                               WHERE Email = 'attorney@law.com' LIMIT 1].Email;
        System.assert(emailString != null);
        System.assertEquals(emailString, 'attorney@law.com','Email is different');
    }

   @isTest
    static void testUpdateContactFieldsWithError(){
        Id recordId = createTestRecord();
        RestRequest request = new RestRequest();
        request.requestUri = BASEURI + recordId + '1';
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"email": "attorney@law.com"}');
        RestContext.request = request;
        // Update email of existing record 
        ContactManagerService.updateContactFields();
        // Verify record was updated
        String emailString = [SELECT Email
                               FROM Contact
                               WHERE Email = 'switftjustice@liberty.com' LIMIT 1].Email;
        System.assert(emailString != null);
        System.assertNotEquals(emailString, 'attorney@law.com','Email is different');
    }




    // Helper method
    static Id createTestRecord(){
        // Create test record
        Contact ContactTest = new Contact(FirstName = 'Saul', LastName = 'Goodman', Email = 'switftjustice@liberty.com');
        insert ContactTest;
        return ContactTest.Id;
    }

}