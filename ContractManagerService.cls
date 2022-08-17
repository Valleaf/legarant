/**
 * ContractManagerService Web Service accessible en REST, qui permet de gérer les contrats.
 *
 * @author trouillet.valentin@brave-otter-3m0fxb.com
 * @version 1.0
 */
@RestResource(urlMapping = '/Contracts/*')
global with sharing class ContractManagerService{
    /**
     * createContract Creates a contract with the parameters specified. Firstly, it checks to see if the contract already exists. If it does, it returns the id. If it does not, it creates the contract and returns it.
     * @param AccountId The id of the account that the contract is associated with.
     * @param startDate The start date of the contract. Format depends on locale. For example, "20/10/2023" in France.
     * @param Term The term of the contract in months.
     *
     */
    @HttpPost
    global static Id createContract(String accountId, String startDate, String term){
        // Create the contract
        try{
            Contract thisContract = new Contract(AccountId = accountId, StartDate = Date.parse(startDate), ContractTerm = Integer.valueOf(term));
            // Save the contract
            insert thisContract;
            return thisContract.Id;
        } catch (Exception e){
            // If an error occurs, return null
            System.debug('Error creating contract: ' + e.getMessage());
            return null;
        }
    }

    /**
     * updateContract Updates a contract with the parameters specified.
     *
     * @param Id (Id):
     * @param FirstName (String):
     * @param LastName (String):
     * @param emailAddress (String):
     *
     */
    @HttpPatch
    global static String updateContractFields(){
        RestRequest request = RestContext.request;
        String ContractId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
        try {
            Contract thisContract = [SELECT Id
                                    FROM Contract
                                    WHERE Id = :ContractId
                                    LIMIT 1];
            // Deserialize the JSON string into name-value pairs
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
            Map<String, Schema.SObjectField> schemaMap = Schema.SObjectType.Contract.fields.getMap();
            // Iterate through each parameter field and value
            for (String fieldName : params.keySet()){
                // Set the field and value on the Contract sObject
                System.debug('Setting field: ' + fieldName + ' to value: ' + params.get(fieldName));
                // Find out the type of field
                Schema.SObjectField field = schemaMap.get(fieldName);
                Schema.DisplayType fieldType = field.getDescribe().getType();
                if(String.valueOf(fieldType) == 'DATE'){
                    thisContract.put(fieldName, Date.parse((String)params.get(fieldName)));
                }else if(String.valueOf(fieldType) == 'INTEGER'){
                    thisContract.put(fieldName, Integer.valueOf((String)params.get(fieldName)));
                }else if(String.valueOf(fieldType) == 'DATETIME'){
                    thisContract.put(fieldName,  (DateTime)Json.deserialize('"'+params.get(fieldName)+'"', DateTime.class));
                } else {
                    thisContract.put(fieldName, params.get(fieldName));
                }
            }
            update thisContract;
            return 'Contract updated';
        }
        catch (Exception e){
            System.debug('Error updating contract: ' + e.getMessage());
            return 'Error updating contract';
        }
    }

}