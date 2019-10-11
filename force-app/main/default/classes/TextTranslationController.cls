public with sharing class TextTranslationController {
    
    @AuraEnabled
    public static List<Translation__c> getTranslations(){
        // return all translations in org
        return [
            SELECT TranslateFrom__c, Text__c, TranslateTo__c, Translation__c, Status__c
            FROM Translation__c
            Order By CreatedDate DESC
        ];
    }
    
    @AuraEnabled
    public static Map<String, Object> saveTranslation(Translation__c translation){
        // saves translation, return message if it fails
        System.debug('#### saveTranslation: translation: ' + translation);
        
        try {
            if(String.isNotEmpty(translation.Text__c) && translation.Text__c.length() > 255)
                throw new GenericException('The text must be a maximum of 255 characters');
            
            Database.insert(translation);
            
        } catch(Exception e){
            System.debug('##### exception on save StackTrace: ' + e.getStackTraceString());
            System.debug('##### exception on save Message: ' + e.getMessage());
            return TextTranslationService.getResponse(false, e.getMessage());
        }
        
        return TextTranslationService.getResponse(true, translation.Id);
    }
    
    @AuraEnabled
    public static Map<String, Object> requestTranslation(String translationId, String text, String toLanguage){
        // requests translation through the API
        System.debug('#### requestTranslation: translationId: ' + translationId);
        System.debug('#### requestTranslation: text: ' + text);
        System.debug('#### requestTranslation: toLanguage: ' + toLanguage);
        
        try {
            Translation__c translation = TranslationDAO.fetchTranslationById(translationId);
            
            // send translation request
            Map<String, Object> requestResponse =
                TranslationRequestService.sendRequest(translation.ExternalId__c, text, TranslationUtils.getLanguageCode(toLanguage));
            
            // if request send fails, updates the Translation__c record status to 'Error'
            if(!Boolean.valueOf( requestResponse.get('success') )){
                String errorMessage = String.valueOf( requestResponse.get('message') );
                
                Database.update(new Translation__c(
                    Id = translationId,
                    Status__c = 'Error',
                    Message__c = errorMessage
                ));
                
                return TextTranslationService.getResponse(false, errorMessage);
            }
            
        } catch(Exception e){
            System.debug('##### exception on request translation StackTrace: ' + e.getStackTraceString());
            System.debug('##### exception on request translation Message: ' + e.getMessage());
            return TextTranslationService.getResponse(false, e.getMessage());
        }
        
        return TextTranslationService.getResponse(true);
    }
    
    
    public class GenericException extends Exception{}
    
}