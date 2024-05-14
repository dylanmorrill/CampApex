trigger PublisherTrigger on Publisher__c (before update) {
  new PublisherTriggerHandler().execute();
}