trigger TriggerOnQuoteItem on QuoteLineItem (before insert, before update) {

    if (Trigger.isInsert) {
        for(QuoteLineItem quoteItem : Trigger.new) {
            if(quoteItem.Unit_Of_Measure__c == 'days') {
                quoteItem.Quantity_Hours__c = quoteItem.Quantity * 8;
            } else {
                quoteItem.Quantity_Hours__c = quoteItem.Quantity;
            }
        }
    }
    if (Trigger.isUpdate) {
        for(QuoteLineItem quoteItem : Trigger.new) {
            if(quoteItem.Unit_Of_Measure__c == 'days') {
                quoteItem.Quantity_Hours__c = quoteItem.Quantity * 8;
            } else {
                quoteItem.Quantity_Hours__c = quoteItem.Quantity;
            }
        }
    }
}