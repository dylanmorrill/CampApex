public class AuthorTriggerHandler {
  private List<Author__c> newList;
  private Map<Id, Author__c> newMap;
  private List<Author__c> oldList;
  private Map<Id, Author__c> oldMap;

  public AuthorTriggerHandler() {
    this.newList = (List<Author__c>)Trigger.new;
    this.newMap = (Map<Id, Author__c>)Trigger.newMap;
    this.oldList = (List<Author__c>)Trigger.old;
    this.oldMap = (Map<Id, Author__c>)Trigger.oldMap;
  }

  public void execute() {
    if (!Trigger.isExecuting) {
      return;
    }
    switch on Trigger.OperationType  {
      when BEFORE_INSERT {
        updateBiographyLastUpdated(newList);
      } when BEFORE_UPDATE {
        updateBiographyLastUpdated(newList, oldMap);
      } when BEFORE_DELETE {
        checkHasPublicationsOnDelete(oldMap);
      }
    }
  }

  private static void checkHasPublicationsOnDelete(Map<Id, Author__c> oldMap) {
    for (AggregateResult agg : [SELECT Author__c Author
                                FROM Publication__c
                                WHERE Author__c in :oldMap.keySet()
                                GROUP BY Author__c]) {
      oldMap.get((Id)agg.get('Author')).addError('Authors with Publications ' +
        'cannot be deleted');
    }
  }

  private static void updateBiographyLastUpdated(List<Author__c> newList) {
    updateBiographyLastUpdated(newList, null);
  }

  private static void updateBiographyLastUpdated(List<Author__c> newList,
    Map<Id, Author__c> oldMap) {

    Boolean isUpdate = oldMap != null;
    for (Author__c a : newList) {
      Boolean isInsertAndBioNull = !isUpdate && String.isBlank(a.Biography__c);
      Boolean isUpdateAndBioNotUpdated = 
        isUpdate && a.Biography__c == oldMap.get(a.Id).Biography__c;
      if (isInsertAndBioNull || isUpdateAndBioNotUpdated) {
        continue;
      }
      a.BiographyLastUpdated__c = Date.today();
    }
  }
}