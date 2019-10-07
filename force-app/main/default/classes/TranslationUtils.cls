public class TranslationUtils {
    
    public static String getLanguageCode(String languageName){
        LanguageCode__c langCode = LanguageCode__c.getValues(languageName);
        if(langCode != null){
            return langCode.Code__c;
        } else {
            return null;
        }
    }
    
}