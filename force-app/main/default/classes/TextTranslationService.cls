public class TextTranslationService {
    
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
    
}
