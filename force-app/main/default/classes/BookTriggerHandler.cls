public class BookTriggerHandler {
  private List<Book__c> triggerNew;
  private Map<Id, Book__c> triggerNewMap;
  private List<Book__c> triggerOld;
  private Map<Id, Book__c> triggerOldMap;

  public BookTriggerHandler() {
    this.triggerNew = (List<Book__c>)Trigger.new;
    this.triggerNewMap = (Map<Id, Book__c>)Trigger.newMap;
    this.triggerOld = (List<Book__c>)Trigger.old;
    this.triggerOldMap = (Map<Id, Book__c>)Trigger.oldMap;
  }

  public void execute() {
    if (!Trigger.isExecuting) {
      return;
    }
    switch on Trigger.OperationType  {
      when BEFORE_INSERT {
        System.debug('We are in the BEFORE_INSERT trigger');
      } when BEFORE_UPDATE {
        System.debug('We are in the BEFORE_UPDATE trigger');
      } when BEFORE_DELETE {
        System.debug('We are in the BEFORE_DELETE trigger');
      } when AFTER_INSERT {
        System.debug('We are in the AFTER_INSERT trigger');
      } when AFTER_UPDATE {
        System.debug('We are in the AFTER_UPDATE trigger');
      } when AFTER_DELETE {
        System.debug('We are in the AFTER_DELETE trigger');
      } when AFTER_UNDELETE {
        System.debug('We are in the AFTER_UNDELETE trigger');
      }
    }
  }
}
