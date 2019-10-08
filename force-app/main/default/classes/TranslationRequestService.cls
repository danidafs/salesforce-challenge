public class TranslationRequestService {
    
    public static Map<String, Object> sendRequest(String externalId, String text, String toLanguage){
        return sendRequest(externalId, text, toLanguage, 'en');
    }
    
    public static Map<String, Object> sendRequest(String externalId, String text, String toLanguage, String fromLanguage){
        // build and send translation request
        System.debug('#### sendRequest: externalId: ' + externalId);
        System.debug('#### sendRequest: text: ' + text);
        System.debug('#### sendRequest: toLanguage: ' + toLanguage);
        System.debug('#### sendRequest: fromLanguage: ' + fromLanguage);
        
        Map<String, Object> respMap;
        
        unbabelapi__Unbabel_Translation_Request__c tr = new unbabelapi__Unbabel_Translation_Request__c();
        
        tr.unbabelapi__Unbabel_From_Language__c = fromLanguage;
        tr.unbabelapi__Unbabel_To_Language__c = toLanguage;
        tr.unbabelapi__Unbabel_Translation_Type__c = 'Machine';
        tr.unbabelapi__Unbabel_Namespace__c = '';
        
        // specify the name of the class to handle the translation
        tr.unbabelapi__Unbabel_Class__c = 'GenericTranslationHandler';
        
        
        Message message = new Message(externalId, text);
        
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
            
            respMap = TextTranslationService.getResponse(true);
        
        // If the request fails updates the Translation Request status to "Request Error" and inserts the TRs
        } else {
            tr.unbabelapi__Unbabel_Status__c = 'Request Error';
            tr.unbabelapi__Unbabel_Error_Log__c = ure.message;
            
            respMap = TextTranslationService.getResponse(false, ure.message);
        }
        
        insert tr;
        return respMap;
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
