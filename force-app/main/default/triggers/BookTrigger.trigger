trigger BookTrigger on Book__c (before update) {
  Book__c newRecord = Trigger.new[0];
	Book__c oldRecord = Trigger.oldMap.get(newRecord.Id);
    
  Boolean hasTitleChanged = newRecord.Title__c != oldRecord.Title__c;
  Boolean hasRatingChanged = newRecord.Rating__c != oldRecord.Rating__c;
  Boolean haveBothFieldsChanged = hasTitleChanged && hasRatingChanged;
  
  if (haveBothFieldsChanged) {
      System.debug('Both fields have changed');
  } else if (hasTitleChanged) {
      System.debug('Title__c has changed');
  } else if (hasRatingChanged) {
      System.debug('Rating__c has changed');
  } else {
      System.debug('Neither field has changed');
  }
}