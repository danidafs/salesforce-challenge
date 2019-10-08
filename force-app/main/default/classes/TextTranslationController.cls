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
            Database.insert(translation);
            
        } catch(Exception e){
            System.debug('##### exception on save StackTrace: ' + e.getStackTraceString());
            System.debug('##### exception on save Message: ' + e.getMessage());
            return getResponse(false, e.getMessage());
        }
        
        return getResponse(true, translation.Id);
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
            Map<String, Object> requestResponse = sendRequest(translation.ExternalId__c, text, TranslationUtils.getLanguageCode(toLanguage));
            
            // if request send fails, updates the Translation__c record status to 'Error'
            if(!Boolean.valueOf( requestResponse.get('success') )){
                String errorMessage = String.valueOf( requestResponse.get('message') );
                
                Database.update(new Translation__c(
                    Id = translationId,
                    Status__c = 'Error',
                    Message__c = errorMessage
                ));
                
                return getResponse(false, errorMessage);
            }
            
        } catch(Exception e){
            System.debug('##### exception on request translation StackTrace: ' + e.getStackTraceString());
            System.debug('##### exception on request translation Message: ' + e.getMessage());
            return getResponse(false, e.getMessage());
        }
        
        return getResponse(true);
    }
    
    
    public static Map<String, Object> sendRequest(String translationId, String text, String toLanguage){
        // build and send translation request
        System.debug('#### sendRequest: translationId: ' + translationId);
        System.debug('#### sendRequest: text: ' + text);
        System.debug('#### sendRequest: toLanguage: ' + toLanguage);
        
        Map<String, Object> respMap;
        
        unbabelapi__Unbabel_Translation_Request__c tr = new unbabelapi__Unbabel_Translation_Request__c();
        
        tr.unbabelapi__Unbabel_From_Language__c = 'en';
        tr.unbabelapi__Unbabel_To_Language__c = toLanguage;
        tr.unbabelapi__Unbabel_Translation_Type__c = 'Machine';
        tr.unbabelapi__Unbabel_Namespace__c = '';
        
        // specify the name of the class to handle the translation
        tr.unbabelapi__Unbabel_Class__c = 'GenericTranslationHandler';
        
        
        Message message = new Message(translationId, text);
        
        System.debug('##### message: ' + message);
        System.debug('##### tr: ' + tr);
        
        // Request Translation to Unbabel
        unbabelapi.UnbabelRestEnvelope ure;
        if(Test.isRunningTest()){
            // fake response if is running test
            if('false'.equals(text)){
                // text variable is used in test class to force request to fail, by sending the string 'false'
                ure = new unbabelapi.UnbabelRestEnvelope(false, null);
            } else {
                ure = new unbabelapi.UnbabelRestEnvelope(true, null);
            }
        } else {
            ure = unbabelapi.UnbabelRestConnectorOutbound.requestTranslation(message, tr);
        }
        
        System.debug('#### ure #### \n\n'+ure+'\n\n');
        
        
        // Sets the TR fields
        tr.unbabelapi__Unbabel_sObject_Id__c = message.Id;
        tr.unbabelapi__Unbabel_sObject__c = '';
        
        // if request is successfull updates the Translation Request status to "Translation Requested" and inserts the TRs
        if (ure.isSuccess) {    
            tr.unbabelapi__Unbabel_Status__c = 'Translation Requested';
            tr.unbabelapi__Unbabel_Translation_Requested_Datetime__c = System.now();
            
            respMap = getResponse(true);
        
        // If the request fails updates the Translation Request status to "Request Error" and inserts the TRs
        } else {
            tr.unbabelapi__Unbabel_Status__c = 'Request Error';
            tr.unbabelapi__Unbabel_Error_Log__c = ure.message;
            
            respMap = getResponse(false, ure.message);
        }
        
        insert tr;
        return respMap;
    }
    
    public static Map<String, Object> getResponse(Boolean success){
        return getResponse(success, null, null);
    }
    
    public static Map<String, Object> getResponse(Boolean success, String message){
        return getResponse(success, message, null);
    }
    
    public static Map<String, Object> getResponse(Boolean success, Id recordId){
        return getResponse(success, null, recordId);
    }
    
    public static Map<String, Object> getResponse(Boolean success, String message, Id recordId){
        return new Map<String, Object>{
            'success'  => success,
            'message'  => message,
            'recordId' => recordId
        };
    }
    
    
    public class Message {
        public String Id;
        public String content;
        
        public Message(String Id, String content) {
            this.Id = Id;        
            this.content = content;
        }
    }
    
}