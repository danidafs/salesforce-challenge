@isTest
public class GenericTranslationHandlerTest {
    
    @testSetup
    static void makeData(){
        Database.insert( CustomSettingBuild.createLanguageCodes() );
        
        Translation__c translationInsert = TranslationBuild.createTranslation('Water', 'Portuguese');
        Database.insert(translationInsert);
    }
    
    
    @isTest
    static void shouldUpdateTranslationStatusTranslated(){
        List<Translation__c> translationList = [SELECT ExternalId__c, Text__c, TranslateTo__c FROM Translation__c];
        System.assertEquals(1, translationList.size());
        Translation__c translationTest = translationList.get(0);
        
        TranslationRequestService.sendRequest(
            translationTest.ExternalId__c,
            translationTest.Text__c,
            TranslationUtils.getLanguageCode(translationTest.TranslateTo__c)
        );
        
        List<unbabelapi__Unbabel_Translation_Request__c> translationRequests = [
            SELECT unbabelapi__Unbabel_Status__c FROM unbabelapi__Unbabel_Translation_Request__c
        ];
        System.assertEquals(1, translationRequests.size());
        
        
        Map<String,String> dataNoObj = new Map<String,String>{
            'Id'      => translationTest.ExternalId__c,
            'content' => 'Água'
        };
        unbabelapi.UnbabelRestEnvelope env = new unbabelapi.UnbabelRestEnvelope(true, null, dataNoObj);
        
        
        Test.startTest();
        new GenericTranslationHandler().execute(env, translationRequests.get(0));
        Test.stopTest();
        
        translationList = [SELECT Status__c, Translation__c FROM Translation__c];
        System.assertEquals(1, translationList.size());
        Translation__c translationAssert = translationList.get(0);
        
        System.assertEquals('Translated', translationAssert.Status__c);
        System.assertEquals('Água', translationAssert.Translation__c);
    }
    
    @isTest
    static void shouldUpdateTranslationStatusError(){
        List<Translation__c> translationList = [SELECT ExternalId__c, Text__c, TranslateTo__c FROM Translation__c];
        System.assertEquals(1, translationList.size());
        Translation__c translationTest = translationList.get(0);
        
        TranslationRequestService.sendRequest(
            translationTest.ExternalId__c,
            translationTest.Text__c,
            TranslationUtils.getLanguageCode(translationTest.TranslateTo__c)
        );
        
        List<unbabelapi__Unbabel_Translation_Request__c> translationRequests = [
            SELECT unbabelapi__Unbabel_Status__c FROM unbabelapi__Unbabel_Translation_Request__c
        ];
        System.assertEquals(1, translationRequests.size());
        
        
        Map<String,String> dataNoObj = new Map<String,String>{
            'Id'      => translationTest.ExternalId__c,
            'content' => ''
        };
        unbabelapi.UnbabelRestEnvelope env = new unbabelapi.UnbabelRestEnvelope(false, 'Generic error', dataNoObj);
        
        
        Test.startTest();
        new GenericTranslationHandler().execute(env, translationRequests.get(0));
        Test.stopTest();
        
        translationList = [SELECT Status__c, Message__c FROM Translation__c];
        System.assertEquals(1, translationList.size());
        Translation__c translationAssert = translationList.get(0);
        
        System.assertEquals('Error', translationAssert.Status__c);
        System.assertEquals('Generic error', translationAssert.Message__c);
    }
    
}
