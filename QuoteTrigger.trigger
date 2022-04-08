trigger QuoteTrigger on Quote (after insert, after update) {
    Set<Id> quoteIds = new Set<Id>();
    Set<Id> opportunityIds = new Set<Id>();
    Set<Id> contactIds = new Set<Id>();
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      
    if (Trigger.isUpdate) {  
        Map<Id, Quote> oldQuote = (Map<Id, Quote>)Trigger.oldMap;
        Map<Id, Quote> newQuote = (Map<Id, Quote>)Trigger.newMap;
        for(Quote quote : newQuote.Values()) {
            if (quote.Status != oldQuote.get(quote.Id).Status && quote.Status == 'Sent' && quote.IsSyncing != true 
                && string.isNotEmpty(quote.OpportunityId)) {
                    quoteIds.add(quote.Id);
            }
            if(quote.Status != oldQuote.get(quote.Id).Status && quote.Status == 'Sent' && string.isNotEmpty(quote.OpportunityId)) {
                    opportunityIds.add(quote.OpportunityId);
            }
        }
        if(!opportunityIds.isEmpty()){
            List<Opportunity> oppsList = [SELECT Id, Decision_Maker__c FROM Opportunity WHERE Id IN :opportunityIds];
            if(!oppsList.isEmpty()){
                for(Opportunity opps : oppsList){
                    contactIds.add(opps.Decision_Maker__c);
                }
            }
        }
        if(!contactIds.isEmpty()){
            List<Contact> con = [SELECT Id, FirstName, LastName, Name, Email FROM Contact WHERE Id IN :contactIds];
            for(Contact myContact : con){
            //Quote for send email
                if (myContact.Email != null && myContact.FirstName != null) {
                    System.debug('Email go send');
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<String> sendTo = new List<String>();
                    mail.setTargetObjectId(myContact.Id);
                    sendTo.add(myContact.Email);
                    mail.setToAddresses(sendTo);
                    mail.setReplyTo('vyacheslav.sokolov@routine-automation.com');
                    mail.setSubject('SUCCESS');
                    String body = 'Dear ' + myContact.FirstName;
                    mail.setHtmlBody(body);
                    mails.add(mail);   
                }    
            }
            if(!contactIds.isEmpty()){
                Messaging.sendEmail(mails);
            }  
        }
        //Quote for send email end
        if(!quoteIds.isEmpty()){
        QuoteHandler.syncQuote(quoteIds);
        }
    }
}