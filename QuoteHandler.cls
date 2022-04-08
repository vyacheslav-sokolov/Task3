public with sharing class QuoteHandler {
    @Future
    public static void syncQuote(Set<Id> quoteIds) {
        List<Quote> quotes = [SELECT Id, OpportunityId FROM Quote WHERE Id IN :quoteIds];
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Quote quote : quotes) {
            oppsToUpdate.add(new Opportunity(Id = quote.OpportunityId, SyncedQuoteId = quote.Id));
        }
        update oppsToUpdate;
    }
}