@isTest
public class TextTranslationControllerTest {
    
    @testSetup
    static void makeData(){
        Database.insert( CustomSettingBuild.createLanguageCodes() );
        
        List<Translation__c> translationListInsert = new List<Translation__c>();
        
        translationListInsert.add( TranslationBuild.createTranslation('Table', 'Portuguese') );
        translationListInsert.add( TranslationBuild.createTranslation('Banana', 'Portuguese') );
        translationListInsert.add( TranslationBuild.createTranslation('Pudding', 'Portuguese', '') );
        translationListInsert.add( TranslationBuild.createTranslation('One', 'Portuguese', 'Um') );
        translationListInsert.add( TranslationBuild.createTranslation('Mustache', 'Portuguese', 'Bigode') );
        translationListInsert.add( TranslationBuild.createTranslation('What', 'Portuguese', 'O que') );
        translationListInsert.add( TranslationBuild.createTranslation('Mouse', 'Portuguese', 'Rato') );
        translationListInsert.add( TranslationBuild.createTranslation('Good', 'Portuguese', 'Bom') );
        
        Database.insert(translationListInsert);
    }
    
    
    @isTest
    static void shouldGetTranslations(){
        List<Translation__c> translations;
        
        Test.startTest();
        translations = TextTranslationController.getTranslations();
        Test.stopTest();
        
        System.assertEquals(8, translations.size());
    }
    
    @isTest
    static void shouldSaveTranslationSuccess(){
        Translation__c translationInsert = TranslationBuild.createTranslation('Water', 'Portuguese');
        
        Map<String, Object> mapResponse;
        
        Test.startTest();
        mapResponse = TextTranslationController.saveTranslation(translationInsert);
        Test.stopTest();
        
        System.assert( Boolean.valueOf(mapResponse.get('success')) );
        System.assert( translationInsert.Id != null );
    }
    
    @isTest
    static void shouldSaveTranslationException(){
        Translation__c translationInsert = TranslationBuild.createTranslation('Water', 'pt');
        
        Map<String, Object> mapResponse;
        
        Test.startTest();
        mapResponse = TextTranslationController.saveTranslation(translationInsert);
        Test.stopTest();
        
        System.assert( !Boolean.valueOf(mapResponse.get('success')) );
        System.assert( String.valueOf(mapResponse.get('message')).contains('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST') );
    }
    
    @isTest
    static void shouldRequestTranslationSuccess(){
        Translation__c translationInsert = TranslationBuild.createTranslation('Water', 'Portuguese');
        TextTranslationController.saveTranslation(translationInsert);
        
        Translation__c translationTest = TranslationDAO.fetchTranslationById(translationInsert.Id);
        System.assert(translationTest != null);
        
        
        System.assertEquals(0, [SELECT count() FROM unbabelapi__Unbabel_Translation_Request__c]);
        
        Map<String, Object> mapResponse;
        
        Test.startTest();
        mapResponse = TextTranslationController.requestTranslation(translationTest.Id, translationTest.Text__c, translationTest.TranslateTo__c);
        Test.stopTest();
        
        List<unbabelapi__Unbabel_Translation_Request__c> translationRequests = [
            SELECT unbabelapi__Unbabel_Status__c FROM unbabelapi__Unbabel_Translation_Request__c
        ];
        
        System.assertEquals(1, translationRequests.size());
        System.assertEquals('Translation Requested', translationRequests.get(0).unbabelapi__Unbabel_Status__c);
        System.assert( Boolean.valueOf( mapResponse.get('success') ) );
    }
    
    @isTest
    static void shouldRequestTranslationFail(){
        // translating the word false, forces the request to fail due to logic in TranslationRequestService.sendRequest
        Translation__c translationInsert = TranslationBuild.createTranslation('false', 'Portuguese');
        TextTranslationController.saveTranslation(translationInsert);
        
        Translation__c translationTest = TranslationDAO.fetchTranslationById(translationInsert.Id);
        System.assert(translationTest != null);
        
        
        System.assertEquals(0, [SELECT count() FROM unbabelapi__Unbabel_Translation_Request__c]);
        
        Map<String, Object> mapResponse;
        
        Test.startTest();
        mapResponse = TextTranslationController.requestTranslation(translationTest.Id, translationTest.Text__c, translationTest.TranslateTo__c);
        Test.stopTest();
        
        List<unbabelapi__Unbabel_Translation_Request__c> translationRequests = [
            SELECT unbabelapi__Unbabel_Status__c FROM unbabelapi__Unbabel_Translation_Request__c
        ];
        
        System.assertEquals(1, translationRequests.size());
        System.assertEquals('Request Error', translationRequests.get(0).unbabelapi__Unbabel_Status__c);
        System.assert( !Boolean.valueOf( mapResponse.get('success') ) );
    }
    
}
