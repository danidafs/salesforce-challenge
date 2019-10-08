public class TranslationDAO {
    
    public static List<Translation__c> fetchTranslationsById(Set<Id> translationIdSet){
        // fetch for a list of Translation__c, using Id as criteria
        return [
            SELECT Name, ExternalId__c, Status__c, Message__c,
                    TranslateFrom__c, Text__c, TranslateTo__c, Translation__c
            FROM Translation__c
            WHERE Id in :translationIdSet
        ];
    }
    
    public static List<Translation__c> fetchTranslationsByExternalId(Set<String> externalIdSet){
        // fetch for a list of Translation__c, using ExternalId__c as criteria
        return [
            SELECT Name, ExternalId__c, Status__c, Message__c,
                    TranslateFrom__c, Text__c, TranslateTo__c, Translation__c
            FROM Translation__c
            WHERE ExternalId__c in :externalIdSet
        ];
    }
    
    
    public static Translation__c fetchTranslationById(Id translationId){
        // fetch for a single Translation__c, using Id as criteria
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
        // fetch for a single Translation__c, using ExternalId__c as criteria
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