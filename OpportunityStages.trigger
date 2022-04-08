trigger OpportunityStages on Opportunity (before insert, before update) {
    List<Opportunity> oppsModified = new List<Opportunity>();
    
    if (Trigger.isUpdate) {
        Map<Id, Opportunity> oldOpportunities = (Map<Id, Opportunity>)Trigger.oldMap;
        Map<Id, Opportunity> newOpportunities = (Map<Id, Opportunity>)Trigger.newMap;
        for(Opportunity opp : newOpportunities.Values()) {
            if (oldOpportunities.get(opp.Id).StageName == 'Quote Sent' && opp.StageName != oldOpportunities.get(opp.Id).StageName
                && opp.StageName != 'New' && opp.StageName != 'Closed Won') {
                    oppsModified.add(opp);
                }
            if ((oldOpportunities.get(opp.Id).StageName == 'New' || oldOpportunities.get(opp.Id).StageName == 'Draft Quote'
                || oldOpportunities.get(opp.Id).StageName == 'Quote Approved') && opp.StageName == 'Closed Won') {
                opp.addError('Refused');
                }
        }
        if(!oppsModified.isEmpty()){
            List<Quote> quoteList = [SELECT Id, Status FROM Quote WHERE OpportunityId IN :oppsModified AND IsSyncing = TRUE];
            if(!quoteList.isEmpty()){
                for(Quote quote : quoteList){
                    quote.Status = 'Rejected';
                }
                update quoteList;
            }
        }
    }
}