/**
 * @description DML manager class which returns the errors of every transaction.
 * @author Javier G. Manzano 
 * @since 01/02/2018 (Created date)
 */
public with sharing class DatabaseManager {
    public static Database.Error[] executeDML(List<SObject> records, String DMLOperation){
        List<Database.Error> errors = new List<Database.Error>();
        
        if(DMLOperation.equalsIgnoreCase('insert')){
            errors.addAll( getInsertErrors(records) );
        }
        else if(DMLOperation.equalsIgnoreCase('update')){
            errors.addAll( getUpdateErrors(records) );
        }
        else if(DMLOperation.equalsIgnoreCase('upsert')){
            errors.addAll( getUpsertErrors(records) );
        }
        else if(DMLOperation.equalsIgnoreCase('delete')){
            errors.addAll( getDeleteErrors(records) );
        }
        
        return errors;
    }
    
    public static Database.Error[] getErrors(List<Database.SaveResult> results){
        Database.Error[] errors = new Database.Error[]{};
        for(Database.SaveResult result : results){
            if(!result.isSuccess()){
                errors.addAll(result.getErrors());
            }
        }
        
        return errors;
    }
    
    public static Database.Error[] getErrors(List<Database.UpsertResult> results){
        Database.Error[] errors = new Database.Error[]{};
        for(Database.UpsertResult result : results){
            if(!result.isSuccess()){
                errors.addAll(result.getErrors());
            }
        }
        
        return errors;
    }
    
    public static Database.Error[] getErrors(List<Database.DeleteResult> results){
        Database.Error[] errors = new Database.Error[]{};
        for(Database.DeleteResult result : results){
            if(!result.isSuccess()){
                errors.addAll(result.getErrors());
            }
        }
        
        return errors;
    }
    
    private static Database.Error[] getInsertErrors(List<SObject> records){
        Database.SaveResult[] results = Database.insert(records, false);
        return getErrors(results);
    }
    
    private static Database.Error[] getUpdateErrors(List<SObject> records){
        Database.SaveResult[] results = Database.update(records, false);
        return getErrors(results);
    }
    
    private static Database.Error[] getUpsertErrors(List<SObject> records){
        Database.UpsertResult[] results = Database.upsert(records, false);
        return getErrors(results);
    }
    
    private static Database.Error[] getDeleteErrors(List<SObject> records){
        Database.DeleteResult[] results = Database.delete(records, false);
        return getErrors(results);
    }
}