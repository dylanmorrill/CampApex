trigger PublicationTrigger on Publication__c (before update) {
  new PublicationTriggerHandler().execute();
}