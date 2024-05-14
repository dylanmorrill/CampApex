trigger BookTrigger on Book__c (before update, after update) {
  new BookTriggerHandler().execute();
}
