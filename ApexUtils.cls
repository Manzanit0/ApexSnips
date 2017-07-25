/**
 * @description Class with overall useful methods when developing in Apex.
 * @author Javier G. Manzano 
 * @since 25/07/2017 (Created date)
 */
public with sharing class ApexUtils {
   
    /**
     * @description Retrieves the CustomFields which contain the input substring in their name.
     *
     * @param sObjectName
     * @param fieldSubstring
     *
     * @return List of the field names
     */
	public static String[] getFieldSubset(String sObjectName, String fieldSubstring){
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectName).getDescribe().fields.getMap();

		String[] fieldSubset = new String[]{};
		for (String fieldName: fieldMap.keySet()) {
			if(fieldName.containsIgnoreCase(fieldSubstring)){
				String developerName = fieldMap.get(fieldName).getDescribe().getName();
				fieldSubset.add(developerName);
			}
		}
        
		return fieldSubset;
	}
}