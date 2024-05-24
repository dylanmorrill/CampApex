trigger BookTrigger on Book__c (before insert, before update, before delete) {
  new BookTriggerHandler().execute();
}
