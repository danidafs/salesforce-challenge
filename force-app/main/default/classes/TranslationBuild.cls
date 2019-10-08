public class TranslationBuild {
    
    public static Translation__c createTranslation(String text, String languageTo){
        return getNewTranslation(text, languageTo, null);
    }
    
    public static Translation__c createTranslation(String text, String languageTo, String translation){
        return getNewTranslation(text, languageTo, translation);
    }
    
    
    public static Translation__c getNewTranslation(String text, String languageTo, String translation){
        return new Translation__c(
            Text__c = text,
            TranslateTo__c = languageTo,
            Status__c = String.isNotEmpty(translation) ? 'Translated' : 'Pending',
            TranslateFrom__c = 'English',
            Translation__c = translation
        );
    }
    
}
