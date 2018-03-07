/**
 * @author Javier G. Manzano 
 * @since 07/03/2018 (Created date)
 */
public class DuplicateMatcher {
    private Map<Schema.sObjectField, List<Schema.sObjectField>> matchFields;
    
    public DuplicateMatcher() {
        matchFields = new Map<Schema.sObjectField, List<Schema.sObjectField>>();
    }
    
    public void mapFields(Schema.sObjectField field1, Schema.sObjectField field2) {
        if(!matchFields.containsKey(field1)) {
            matchFields.put(field1, new List<Schema.sObjectField>());
        }
        
        matchFields.get(field1).add(field2);
    }
    
    public Boolean areDuplicate(SObject record1, SObject record2) {
        for(Schema.sObjectField field : matchFields.keySet()) {
            for(Schema.sObjectField otherField : matchFields.get(field)) {
                if(record1.get(field) == record2.get(otherField)) {
                    return true;
                }
            }
        }
        
        return false;
    }
}