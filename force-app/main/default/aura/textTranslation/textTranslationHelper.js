({
    loopRefresh : function(component, helper) {
        setTimeout($A.getCallback(function(){
            console.log('###### refresh ######');
            
            helper.fetchTranslations(component);
            helper.loopRefresh(component, helper);
            
		}), 15000);
    },
    
    fetchTranslations : function(component) {
        var action = component.get('c.getTranslations');
        
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                var translations = response.getReturnValue();
                component.set('v.allTranslations', translations);
                component.set('v.dataSize', translations.length);
                
                this.paginate(component);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    paginate : function(component) {
        var translations = component.get('v.allTranslations');
        console.log('#### translations: ' + translations);
        
        var pageNumber = 1;
        var pageMap = {};
        
        var pageCount = 0;
        var pageTranslations = [];
        
        for(var i=0; i<translations.length; i++) {
            pageTranslations.push( translations[i] );
            pageCount += 1;
            
            if(pageCount == 10){
                pageMap[pageNumber] = pageTranslations;
                pageTranslations = [];
                pageCount = 0;
                pageNumber += 1;
            }
        }
        
        var lastPage;
        
        if(pageTranslations.length > 0){
            pageMap[pageNumber] = pageTranslations;
            lastPage = pageNumber;
        } else {
            lastPage = pageNumber - 1;
        }
        
        console.log('##### pageMap: ', pageMap);
        
        component.set('v.mapTranslations', pageMap);
        component.set('v.pageTranslations', pageMap[component.get('v.currentPage')]);
        component.set('v.lastPage', lastPage);
    },
    
    save : function(component, translationObj) {
        console.log('#### save ####');
        var action = component.get('c.saveTranslation');
        
        action.setParams({"translation":translationObj});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('#### save response state: ' + state);
			
			if (state === "SUCCESS") {
                var saveResponse = response.getReturnValue();
                console.log('save: saveResponse[success]: ' + saveResponse['success']);
                console.log('save: saveResponse[recordId]: ' + saveResponse['recordId']);
                console.log('save: saveResponse[message]: ' + saveResponse['message']);
                
                if(saveResponse['success'] == 'true'){
                    this.request(component, saveResponse['recordId']);
                    
                } else {
                    this.showToast(saveResponse['message'], '10000', 'error');
                    component.set('v.showSpinner', false);
                }
				
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
		
		$A.enqueueAction(action);
    },
    
    request : function(component, translationId) {
        console.log('#### request ####');
        var action = component.get('c.requestTranslation');
        
        action.setParams({
            "translationId":translationId,
            "text":component.get('v.textTranslate'),
            "toLanguage":component.get('v.translateTo')
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('#### request response state: ' + state);
			
			if (state === "SUCCESS") {
                var reqResponse = response.getReturnValue();
                
                console.log('request: reqResponse[success]: ' + reqResponse['success']);
                console.log('request: reqResponse[recordId]: ' + reqResponse['recordId']);
                console.log('request: reqResponse[message]: ' + reqResponse['message']);
                
                if(reqResponse['success'] == 'true'){
                    $A.get("e.force:refreshView").fire();
                    this.showToast('Translation successfully requested', '3000', 'success');
                    
                } else {
                    this.showToast(reqResponse['message'], '10000', 'error');
                }
                
                component.set('v.showSpinner', false);
				
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
		
		$A.enqueueAction(action);
    },
    
    isEmpty : function(value) {
        return value == null || value == undefined || value == '';
    },
    
    showToast : function(message, duration, type) {
        console.log('### showToast');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message" : message,
            "duration" : duration,
            "type" : type
        });
        toastEvent.fire();
    }
})