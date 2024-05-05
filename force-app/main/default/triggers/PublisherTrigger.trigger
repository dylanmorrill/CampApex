trigger PublisherTrigger on Publisher__c (before update) {

  Publisher__c newRecord = Trigger.new[0];
	Publisher__c oldRecord = Trigger.oldMap.get(newRecord.Id);

  Boolean hasAverageRatingChanged = newRecord.AverageRating__c != 
    oldRecord.AverageRating__c;

  if (hasAverageRatingChanged) {
    CampApexTests.confirmChallange();
  }
}