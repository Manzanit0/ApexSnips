/**
 * @author Javier G. Manzano 
 * @since 07/03/2018 (Created date)
 */
public with sharing class Deduplicator {
    
    private DuplicateMatcher matcher;
    private DuplicateRule dupRule;
    
    public Deduplicator(DuplicateMatcher matcher, DuplicateRule dupRule) {
        this.matcher = matcher;
        this.dupRule = dupRule;
    }
    
    public List<DuplicateRecordSet> createDuplicateReportingData(List<SObject> records) {
        Map<String, List<DuplicateRecordItem>> sortedDuplicateItems = getDuplicateRecordItemsByRecordId(records);
    
        // Since we need to provide a DuplicateRecordSet with Id to the Items, we need to insert them first.
        List<DuplicateRecordSet> duplicateSets = insertDuplicateRecordSets(sortedDuplicateItems.size(), dupRule);
        
        List<DuplicateRecordItem> allDuplicateItems = new List<DuplicateRecordItem>();
        
        for(String key : sortedDuplicateItems.keySet()) {
            DuplicateRecordSet duplicateSet = duplicateSets[0];
            duplicateSets.remove(0);
            
            for(DuplicateRecordItem item : sortedDuplicateItems.get(key)) {
                item.DuplicateRecordSetId = duplicateSet.Id;
                allDuplicateItems.add(item);
            }
        }
        
        insert allDuplicateItems;
        
        return duplicateSets;
    }
    
    private Map<String, List<DuplicateRecordItem>> getDuplicateRecordItemsByRecordId(List<SObject> duplicates) {
        Map<String, List<DuplicateRecordItem>> duplicateSets = new Map<String, List<DuplicateRecordItem>>();
        Set<String> processedPairs = new Set<String>();
        
        for(SObject record1 : duplicates) {
            for(SObject record2 : duplicates) {
                if(areDifferent(record1, record2) && haveNotBeenProcessed(processedPairs, record1, record2) && matcher.areDuplicate(record1, record2)) {
                    if(!duplicateSets.containsKey(record1.Id)) {
                        duplicateSets.put(record1.Id, new List<DuplicateRecordItem>());
                        duplicateSets.get(record1.Id).add(new DuplicateRecordItem(RecordId = record1.Id));
                    }
                    
                    duplicateSets.get(record1.Id).add(new DuplicateRecordItem(RecordId = record2.Id));
                    processedPairs.add('' + record1.Id + record2.Id);
                }
            }
        }
        
        return duplicateSets;
    }
    
    private List<DuplicateRecordSet> insertDuplicateRecordSets(Integer amount, DuplicateRule dupRule) {
        List<DuplicateRecordSet> duplicateSets = new List<DuplicateRecordSet>();
        for(Integer i = 0; i < amount; i++) {
            duplicateSets.add(new DuplicateRecordSet(DuplicateRuleId = dupRule.Id));
        }
        
        insert duplicateSets;
        
        return duplicateSets;
    }
    
    private Boolean areDifferent(SObject record1, SObject record2) {
        return (record1 != null) && (record2 != null) && (record1.Id != record2.Id);
    }
    
    private Boolean haveNotBeenProcessed(Set<String> processedPairs, SObject record1, SObject record2) {
        return !processedPairs.contains('' + record1.Id + record2.Id) && !processedPairs.contains('' + record2.Id + record1.Id);
    }
    
}