public with sharing class DownloadRecordsController {
   
    /**
     * @description Retrieves all sObjects the user can query, access, update, and search
     * @return List of sObject API names
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getAllObjects(){
        
        List<String> objectNames = new List<String>();
        Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();

        for(Schema.SObjectType objType : objectMap.values()){
            //get object desribe
            Schema.DescribeSObjectResult objResult = objType.getDescribe();

            //check the object is accessable
            if(objResult.isQueryable() && objResult.isAccessible() && objResult.isUpdateable() && objResult.isSearchable()){
                  String name = objResult.getName();

                  if(!name.containsIgnoreCase('history') && !name.containsIgnoreCase('tag') 
                     && !name.containsIgnoreCase('share') && !name.containsIgnoreCase('feed')){
                        objectNames.add(name);
                     }
            }
        }
        objectNames.sort();

        return objectNames;
     }

     /***
      * 
      * @author - Gokul
      *
      * @description - Retreive all the records based on the selected objectName
      * @param - String objectName - passing the selected objectName
      * @return RecordsWrapper containing nameField and list of records
      */

      @AuraEnabled
      public static RecordsWrapper retrieveRecords(String objectName){
          
          if(String.isBlank(objectName)){
               throw new AuraHandledException('Object Name Cannot be Blank');
          }

          //get the object type 
          SObjectType objType = Schema.getGlobalDescribe().get(objectName);

           //check the object is queryable are not go deep inside the fields
           DescribeSObjectResult objDescribe = objType.getDescribe();

           if(!objDescribe.isAccessible() || !objDescribe.isQueryable()){
              throw new AuraHandledException( objectName + 'you do not have a permission to query and access the object');
           }

           String nameField = 'Name';

           Map<String,SObjectField> fieldMaps = objDescribe.fields.getMap();

           for(SObjectField fields : fieldMaps.values()){
               DescribeFieldResult fieldResult = fields.getDescribe();

               if(fieldResult.isNameField()){
                   nameField = fieldResult.getName();
                   break;
               }
           }

          String query = 'Select Id, ' + nameField + ', CreatedDate, LastModifiedDate From ' + String.escapeSingleQuotes(objectName) + ' Limit 50000';

          RecordsWrapper wrapper = new RecordsWrapper();
          wrapper.nameField = nameField;
          wrapper.records = Database.query(query);

          return wrapper;
      }

      /**
       * @description Wrapper class to return both the nameField and records to LWC
       */
      public class RecordsWrapper {
          @AuraEnabled public String nameField { get; set; }
          @AuraEnabled public List<SObject> records { get; set; }
      }
}