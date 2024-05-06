trigger BookTrigger on Book__c (before update) {
  Set<Id> publishereIds = new Set<Id>();
  for (Book__c o : Trigger.new) {
    if (o.Publisher__c != null) {
      publishereIds.add(o.Publisher__c);
    }
  }
  If (publishereIds.isEmpty()) {
    return;
  }
  Map<Id, Publisher__c> objectThreeMap = new Map<Id, Publisher__c>
    ([SELECT Id, Name
      FROM Publisher__c
      WHERE Id in :publishereIds]);
  
  for (Book__c o : Trigger.new) {
    if (o.Publisher__c != null) {
      System.debug('For Book__c "' + o.Name + '", the parent Publisher__c is "' + 
        objectThreeMap.get(o.Publisher__c).Name + '"');
    }
  }
}