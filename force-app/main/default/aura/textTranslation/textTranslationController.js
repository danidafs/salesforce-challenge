({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'From Language', fieldName: 'TranslateFrom__c', type: 'text'},
            {label: 'Original Text', fieldName: 'Text__c', type: 'text'},
            {label: 'To Language', fieldName: 'TranslateTo__c', type: 'text'},
            {label: 'Translated Text', fieldName: 'Translation__c', type: 'text'},
            {label: 'Status', fieldName: 'Status__c', type: 'text'}
        ]);
        
        // fetch translations for the first time
        helper.fetchTranslations(component);
        
        // start refreshing page in loop
        helper.loopRefresh(component, helper);
    },
    
    checkSubmitAvailability : function(component, event, helper) {
        // checks if submit button can be available
        var textTranslate = component.get('v.textTranslate');
        var translateTo = component.get('v.translateTo');
        
        component.set('v.submitDisabled', ( helper.isEmpty(textTranslate) || helper.isEmpty(translateTo) ));
    },
    
    processSubmit : function(component, event, helper) {
        // process save to subsequently request translation using unbabel API
        component.set('v.showSpinner', true);
        
        var translationObj = {
            'TranslateFrom__c': "English",
            'Text__c': component.get('v.textTranslate'),
            'TranslateTo__c': component.get('v.translateTo'),
            'Status__c': 'Pending'
        };
        
        helper.save(component, translationObj);
    },
    
    nextPage : function(component, event, helper) {
        // set next page and update records
        var nextPage = component.get('v.currentPage') + 1;
        var records = component.get('v.mapTranslations')[nextPage];
        
        console.log('#### next page records: ' + records);
        
        component.set('v.currentPage', nextPage);
        component.set('v.pageTranslations', records);
    },
    
    previousPage : function(component, event, helper) {
        // set previous page and update records
        var previousPage = component.get('v.currentPage') - 1;
        var records = component.get('v.mapTranslations')[previousPage];
        
        console.log('#### previous page records: ' + records);
        
        component.set('v.currentPage', previousPage);
        component.set('v.pageTranslations', records);
    }
})