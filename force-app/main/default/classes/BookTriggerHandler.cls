public class BookTriggerHandler {
  private List<Book__c> newList;
  private Map<Id, Book__c> newMap;
  private List<Book__c> oldList;
  private Map<Id, Book__c> oldMap;

  public BookTriggerHandler() {
    this.newList = (List<Book__c>)Trigger.new;
    this.newMap = (Map<Id, Book__c>)Trigger.newMap;
    this.oldList = (List<Book__c>)Trigger.old;
    this.oldMap = (Map<Id, Book__c>)Trigger.oldMap;
  }

  public void execute() {
    if (!Trigger.isExecuting) {
      return;
    }
    switch on Trigger.OperationType  {
      when BEFORE_INSERT {
        updateRetailPrice(newList);
      } when BEFORE_UPDATE {
        updateRetailPrice(newList, oldMap);
      } when BEFORE_DELETE {
        checkDeletePermPublishedBook(oldList);
      }
    }
  }

  private static void checkDeletePermPublishedBook(List<Book__c> oldList) {
    if (FeatureManagement.checkPermission('DeletePublishedBooks')) {
      return;
    }
    for (Book__c b : oldList) {
      if (b.PublicationDate__c <= Date.today()) {
        b.addError('You don\'t have permission to delete published Books');
      }
    }
  }

  private static void updateRetailPrice(List<Book__c> newList) {
    updateRetailPrice(newList, null);
  }

  private static void updateRetailPrice(List<Book__c> newList,
    Map<Id, Book__c> oldMap) {

    //Create a few collections to help us out
    Boolean isUpdate = oldMap != null;
    List<Book__c> booksToUpdate = new List<Book__c>();
    Set<Id> allGenres = new Set<Id>();
    Set<Id> allPublishers = new Set<Id>();
    Map<Id, Map<Id, Decimal>> publisherToGenreAndDiscount
      = new Map<Id, Map<Id, Decimal>>();

    /*Loop through trigger.New and get all the Publisher and Genre record Ids
      from each Book*/
    for (Book__c b : newList) {
      if (isUpdate && b.ListPrice__c == oldMap.get(b.Id).ListPrice__c) {
        continue;
      }
      allPublishers.add(b.Publisher__c);
      allGenres.add(b.Genre__c);
      booksToUpdate.add(b);
    }
    if (booksToUpdate.isEmpty()) {
      return;
    }

    /*SOQL for the active Publisher Discount records (if there are any), related to
      each Publisher and Genre in our collections*/
    for (Publisher_Discount__c pd : [SELECT Id, Discount__c, Genre__c, 
                                                Publisher__c
                                     FROM Publisher_Discount__c
                                     WHERE Genre__c IN :allGenres
                                     AND Publisher__c IN :allPublishers
                                     AND Active__c = true]) {

      /*For each Publisher Discount record, put the Publisher Id in a Map as
        the key, and the value will be another map with the key being the
        Genre Id and the value being the respecive discount. This might seem
        confusing - but it is not! We are just created a data structure that
        holds the discount amount for each Genre for each Publisher - so we
        will know, for each Publisher, what the discount is (if there is any)
        for each Genre*/
       
      if (!publisherToGenreAndDiscount.containsKey(pd.Publisher__c)) {
        publisherToGenreAndDiscount.put(pd.Publisher__c, 
          new Map<Id, Decimal>());
      }
      publisherToGenreAndDiscount.get(pd.Publisher__c).put(
        pd.Genre__c, pd.Discount__c);
    }

    /*Loop again through trigger.New to set the RetailPrice__c initially to the
      ListPrice__c, and then, if their is a discount for the Books Publisher
      and Genre, use the Multiplication assignment operator (*=)
      to make the RetailPrice equal itself times the discount value*/
    for (Book__c b : booksToUpdate) {
      b.RetailPrice__c = b.ListPrice__c;
      if (publisherToGenreAndDiscount.containsKey(b.Publisher__c)) {
        Map<Id, Decimal> genreAndDiscount 
          = publisherToGenreAndDiscount.get(b.Publisher__c);
        if (genreAndDiscount.containsKey(b.Genre__c)) {
          b.RetailPrice__c *= 
            publisherToGenreAndDiscount.get(b.Publisher__c).get(b.Genre__c);
        }
      }
    }
  }
}
