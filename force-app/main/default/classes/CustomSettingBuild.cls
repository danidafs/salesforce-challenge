public class CustomSettingBuild {
    
    public static List<LanguageCode__c> createLanguageCodes(){
        List<String> languages = new List<String>{
            'ar:Arabic',
            'bg:Bulgarian',
            'da:Danish',
            'de:German',
            'el:Greek',
            'en:English',
            'es:Spanish',
            'es-latam:Spanish(Latam)',
            'fi:Finnish',
            'fr:French',
            'hi:Hindi',
            'id:Indonesian',
            'it:Italian',
            'ja:Japanese',
            'ko:Korean',
            'nl:Dutch',
            'no:Norwegian',
            'pl:Polish',
            'pt:Portuguese',
            'pt-br:Portuguese(BR)',
            'ro:Romanian',
            'ru:Russian',
            'sv:Swedish',
            'th:Thai',
            'tr:Turkish',
            'vi:Vietnamese',
            'zh-CN:Chinese (simplified)',
            'zh-TW:Chinese (Traditional)'
        };
        
        List<LanguageCode__c> langCodeList = new List<LanguageCode__c>();
        
        for(String language : languages){
            langCodeList.add(new LanguageCode__c(
                Name = language.split(':').get(1),
                Code__c = language.split(':').get(0)
            ));
        }
        
        return langCodeList;
    }
    
}
