public with sharing class DownloadRecordsController {
   
    
     /**
     * @description Retrieves all sObjects the user can query, access, update, and search
     * @return List of sObject API names
     */
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
}