public class TranslationDAO {
    
    public static List<Translation__c> fetchTranslationsById(Set<Id> translationIdSet){
        return [
            SELECT Status__c,
                    Translation__c,
                    Message__c,
                    ExternalId__c
            FROM Translation__c
            WHERE Id in :translationIdSet
        ];
    }
    
    public static List<Translation__c> fetchTranslationsByExternalId(Set<String> externalIdSet){
        return [
            SELECT Status__c,
                    Translation__c,
                    Message__c,
                    ExternalId__c
            FROM Translation__c
            WHERE ExternalId__c in :externalIdSet
        ];
    }
    
    
    public static Translation__c fetchTranslationById(Id translationId){
        if(String.isEmpty(translationId)) return null;
        try {
            List<Translation__c> translationList = fetchTranslationsById(new Set<Id>{translationId});
            return translationList.get(0);
        } catch(Exception e){
            System.debug('TranslationDAO.fetchTranslationById - Could not retrieve Translation: ' + e.getMessage());
            return null;
        }
    }
    
    public static Translation__c fetchTranslationByExternalId(String externalId){
        if(String.isEmpty(externalId)) return null;
        try {
            List<Translation__c> translationList = fetchTranslationsByExternalId(new Set<String>{externalId});
            return translationList.get(0);
        } catch(Exception e){
            System.debug('TranslationDAO.fetchTranslationById - Could not retrieve Translation: ' + e.getMessage());
            return null;
        }
    }
    
}