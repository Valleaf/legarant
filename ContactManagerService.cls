/**
 * ContactManagerService Web Service accessible en REST, qui permet de gérer les contacts.
 *
 * @author trouillet.valentin@brave-otter-3m0fxb.com
 * @version 1.0
 */
@RestResource(urlMapping = '/Contacts/*')
global with sharing class ContactManagerService{
    /**
     * createContact Creates a contact with the parameters specified. Firstly, it checks to see if the contact already exists. If it does, it returns the id. If it does not, it creates the contact and returns it.
     *
     * @param FirstName (String):
     * @param LastName (String):
     * @param emailAddress (String):
     *
     * @return Id:
     *
     */
    @HttpPost
    global static Id createContact(String FirstName, String LastName, String emailAddress){

        // Check if the contact already exists
        Contact[] c = [SELECT Id
                       FROM Contact
                       WHERE email = :emailAddress];
        if (c.isEmpty()){
            // Create the contact
            Contact thisContact = new Contact(FirstName = FirstName, LastName = LastName, email = emailAddress);
            try{
                // Save the contact
                insert thisContact;
            } catch (Exception e){
                // If an error occurs, return null
                System.debug('Error creating contact: ' + e.getMessage());
                return null;
            }
            return thisContact.Id;
        } else
            // If the contact already exists, return the id
            return c[0].Id;
    }

    /**
     * deleteContact Deactive a contact with the parameters specified.
     *
     * @param Id (Id):
     *
     */
    @HttpDelete
    global static String deleteContact(){
        RestRequest request = RestContext.request;
        // Get the id from the request
        String ContactId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
        try{
            // Deactivate the contact
            Contact c = [SELECT Id
                         FROM Contact
                         WHERE Id = :ContactId];
            c.IsActive__c = false;
            update c;
            return 'Contact deactivated';
        } catch (Exception e){
            System.debug('Error updating contact: ' + e.getMessage());
            return 'Error deactivating contact: ' + e.getMessage();
        }
    }

    /**
     * updateContact Updates a contact with the parameters specified.
     *
     * @param Id (Id):
     * @param FirstName (String):
     * @param LastName (String):
     * @param emailAddress (String):
     *
     */
    @HttpPatch
    global static String updateContactFields(){
        RestRequest request = RestContext.request;
        String ContactId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
        try{
            Contact thisContact = [SELECT Id
                                   FROM Contact
                                   WHERE Id = :ContactId
                                   LIMIT 1];
            // Deserialize the JSON string into name-value pairs
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
            // Iterate through each parameter field and value
            for (String fieldName : params.keySet()){
                // Set the field and value on the Contact sObject
                System.debug('Setting field: ' + fieldName + ' to value: ' + params.get(fieldName));
                thisContact.put(fieldName, params.get(fieldName));
            }
            update thisContact;
            return 'Contact updated';
        } catch (QueryException e){
            return 'Contact not found';
        }
    }

}