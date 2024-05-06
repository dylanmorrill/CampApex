trigger PublicationTrigger on Publication__c (before update) {
  Set<Id> bookIds = new Set<Id>();
  for (Publication__c p : Trigger.new) {
    if (p.Book__c != null) {
      bookIds.add(p.Book__c);
    }
  }

  for (Book__c b : [SELECT Id, Name
                    FROM Book__c
                    WHERE Id in : bookIds]) {   
    CampApexTests.confirmChallange(b.Name);
  }
}