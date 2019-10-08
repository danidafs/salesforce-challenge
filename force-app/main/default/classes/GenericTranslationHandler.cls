global class GenericTranslationHandler implements unbabelapi.ITranslationHandler{
    
    global unbabelapi.UnbabelRestEnvelope execute(unbabelapi.UnbabelRestEnvelope env, unbabelapi__Unbabel_Translation_Request__c tr) {
        // Response envelope
        system.debug('#### env: ' + env);
        
        // sObject payload
        system.debug('#### env.data: ' + env.data);
        // Generic payload
        system.debug('#### env.dataNoObj: ' + env.dataNoObj);
        // translation success
        system.debug('#### env.isSuccess: ' + env.isSuccess);
        // error message
        system.debug('#### env.message: ' + env.message);
        
        try {
            Translation__c translation = TranslationDAO.fetchTranslationByExternalId( env.dataNoObj.get('Id') );
            
            // set status to Translation__c record
            if(translation != null){
                if(env.isSuccess){
                    translation.Status__c = 'Translated';
                    translation.Translation__c = env.dataNoObj.get('content');
                } else {
                    translation.Status__c = 'Error';
                    translation.Message__c = env.message;
                }
                
                Database.update(translation);
            }
            
        } catch(Exception e){
            System.debug('###### getStackTraceString: ' + e.getStackTraceString());
            System.debug('###### getMessage: ' + e.getMessage());
            System.debug('###### getLineNumber: ' + e.getLineNumber());
        }
        
        return env;
    }
    
}