public class PublicationTriggerHandler {
  private List<Publication__c> triggerNew;
  private Map<Id, Publication__c> triggerNewMap;
  private List<Publication__c> triggerOld;
  private Map<Id, Publication__c> triggerOldMap;

  public PublicationTriggerHandler() {
    this.triggerNew = (List<Publication__c>)Trigger.new;
    this.triggerNewMap = (Map<Id, Publication__c>)Trigger.newMap;
    this.triggerOld = (List<Publication__c>)Trigger.old;
    this.triggerOldMap = (Map<Id, Publication__c>)Trigger.oldMap;
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