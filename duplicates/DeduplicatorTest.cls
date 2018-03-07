
@IsTest
public with sharing class DeduplicatorTest {

    @IsTest
    static void oneDuplicateSetOneRecord() {
        // Prepare
        Lead l1 = UnitTestFactory.createLead('some@email.com');
        Lead l2 = UnitTestFactory.createLead('another@email.com');
        l2.AlternativeEmailAddress1__c = 'some@email.com';
        Lead[] leads = new Lead[] {l1, l2};
        insert leads;
    
        Deduplicator dedup = createTestDeduplicator('Apex_Duplicates');
        
        // Act
        Test.startTest();
        dedup.createDuplicateReportingData(leads);
        Test.stopTest();
        
        // Assert
        DuplicateRecordSet[] dupSets = [SELECT Id, (SELECT Id FROM DuplicateRecordItems) FROM DuplicateRecordSet];
        System.assert(!dupSets.isEmpty(), 'No duplicate sets have been created.');
        System.assertEquals(1, dupSets.size(), 'More sets than expected have been created');
        System.assert(!dupSets[0].DuplicateRecordItems.isEmpty(), 'No duplicate items have been inserted');
        System.assertEquals(2, dupSets[0].DuplicateRecordItems.size(), 'The amount of duplicate items is incorrect');
    }
    
    @IsTest
    static void oneDuplicateSetMultipleRecords() {
        // Prepare
        Lead l1 = UnitTestFactory.createLead('some@email.com');
        Lead l2 = UnitTestFactory.createLead('another@email.com');
        l2.AlternativeEmailAddress1__c = 'some@email.com';
        Lead l3 = UnitTestFactory.createLead('yetAnother@email.com');
        l3.AlternativeEmailAddress2__c = 'some@email.com';
        Lead[] leads = new Lead[] {l1, l2, l3};
        insert leads;
    
        Deduplicator dedup = createTestDeduplicator('Apex_Duplicates');
    
        // Act
        Test.startTest();
        dedup.createDuplicateReportingData(leads);
        Test.stopTest();
    
        // Assert
        DuplicateRecordSet[] dupSets = [SELECT Id, (SELECT Id FROM DuplicateRecordItems) FROM DuplicateRecordSet];
        System.assert(!dupSets.isEmpty(), 'No duplicate sets have been created.');
        System.assertEquals(1, dupSets.size(), 'More sets than expected have been created');
        System.assert(!dupSets[0].DuplicateRecordItems.isEmpty(), 'No duplicate items have been inserted');
        System.assertEquals(3, dupSets[0].DuplicateRecordItems.size(), 'The amount of duplicate items is incorrect');
    }
    
    @IsTest
    static void multipleDuplicateSets() {
        // Prepare
        Lead l1 = UnitTestFactory.createLead('some@email.com');
        Lead l2 = UnitTestFactory.createLead('another@email.com');
        l2.AlternativeEmailAddress1__c = 'some@email.com';
        Lead l3 = UnitTestFactory.createLead('yetAnother@email.com');
        l3.AlternativeEmailAddress2__c = 'some@email.com';
        Lead[] leads = new Lead[] {l1, l2, l3};
        
        Lead l4 = UnitTestFactory.createLead('next@email.com');
        Lead l5 = UnitTestFactory.createLead('pimpam@email.com');
        l5.AlternativeEmailAddress1__c = 'next@email.com';
        Lead l6 = UnitTestFactory.createLead('ohohoh@email.com');
        l6.AlternativeEmailAddress2__c = 'next@email.com';
        leads.addAll(new Lead[]{l4, l5, l6});
        
        insert leads;
        
        Deduplicator dedup = createTestDeduplicator('Apex_Duplicates');
        
        // Act
        Test.startTest();
        dedup.createDuplicateReportingData(leads);
        Test.stopTest();
        
        // Assert
        DuplicateRecordSet[] dupSets = [SELECT Id, (SELECT Id FROM DuplicateRecordItems) FROM DuplicateRecordSet];
        System.assert(!dupSets.isEmpty(), 'No duplicate sets have been created.');
        System.assertEquals(2, dupSets.size(), 'More sets than expected have been created');
        System.assert(!dupSets[0].DuplicateRecordItems.isEmpty(), 'No duplicate items have been inserted');
        System.assert(!dupSets[1].DuplicateRecordItems.isEmpty(), 'No duplicate items have been inserted');
        System.assertEquals(3, dupSets[0].DuplicateRecordItems.size(), 'The amount of duplicate items is incorrect');
        System.assertEquals(3, dupSets[1].DuplicateRecordItems.size(), 'The amount of duplicate items is incorrect');
    }
    
    private static Deduplicator createTestDeduplicator(String dupRuleName) {
        DuplicateMatcher matcher = new DuplicateMatcher();
        matcher.mapFields(Lead.Email, Lead.AlternativeEmailAddress1__c);
        matcher.mapFields(Lead.Email, Lead.AlternativeEmailAddress2__c);
    
        DuplicateRule dupRule = [SELECT Id FROM DuplicateRule WHERE DeveloperName =: dupRuleName];
        
        return new Deduplicator(matcher, dupRule);
    }
}