trigger AuthorTrigger on Author__c (before insert, before update, 
  before delete) {
    
  new AuthorTriggerHandler().execute();
}
