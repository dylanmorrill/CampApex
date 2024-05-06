public class CampApexTests {
  private static ChallangeConfirmation confirmer;

  public CampApexTests() {
    confirmer = new ChallangeConfirmation();
  }

  public void bulkificationExecutionContext() {
    System.Savepoint sp = Database.setSavepoint();
    assertTriggerExists('PublicationTrigger');
    Set<String> bookNames = new Set<String> {
      'To Kill a Mockingbird', '1984', 'The Great Gatsby',
      'Pride and Prejudice', 'The Catcher in the Rye', 'The Hobbit',
      'The Lord of the Rings', 'Brave New World', 'Animal Farm',
      'The Chronicles of Narnia', 'The Da Vinci Code',
      'Harry Potter and the Sorcerer\'s Stone', 'The Hunger Games',
      'The Alchemist', 'Lord of the Flies', 'The Kite Runner',
      'The Catcher in the Rye', 'To Kill a Mockingbird',
      'Harry Potter and the Chamber of Secrets',
      'Harry Potter and the Prisoner of Azkaban',
      'Harry Potter and the Goblet of Fire',
      'Harry Potter and the Order of the Phoenix',
      'Harry Potter and the Half-Blood Prince',
      'Harry Potter and the Deathly Hallows', 'The Great Gatsby',
      'Fahrenheit 451', 'The Book Thief', 'The Hobbit', 'The Lord of the Rings',
      'The Hunger Games', 'Twilight', 'The Fault in Our Stars',
      'The Girl with the Dragon Tattoo', 'Gone with the Wind',
      'The Help', 'The Hitchhiker\'s Guide to the'};
    List<Book__c> booksToInsert = new List<Book__c>();
    List<Publication__c> publicationsToInsert = new List<Publication__c>();
    for (String bookName : bookNames) {
      booksToInsert.add(new Book__C(Name = bookName));
    }
    insert booksToInsert;
    for (Book__c b : booksToInsert) {
      publicationsToInsert.add(new Publication__c(Book__c = b.Id));
    }
    insert publicationsToInsert;
    update publicationsToInsert;
    Assert.isTrue(!confirmer.logStrings.isEmpty(), 
      'You did not confirm any book names - please review your code');
    Assert.isTrue(confirmer.logStrings.containsAll(bookNames), 
      'Some book names were confirmed but not all - please review your code');
    Assert.isTrue(Limits.getQueries() < 5, 'You used ' + 
      Limits.getQueries() + ' queries, but must only use one to complete ' +
      'this challange');
    System.debug(JSON.serializePretty(confirmer));
    Database.rollback(sp);
  }

  public void triggerContextVariables() {
    System.Savepoint sp = Database.setSavepoint();
    assertTriggerExists('PublisherTrigger');
    Publisher__c p = [SELECT Id
                      FROM Publisher__c
                      LIMIT 1];
    //Confirm code not hit when AverageRating__c has not changed
    update p;
    Assert.isFalse(confirmer.isConfirmed(), 
      'Your code was hit event when AvererageRating__c did not change');

    //Confirm code is hit when AverageRating__c has changed
    confirmer.clearConfirmation();
    p.AverageRating__c = Math.random() * 10000;
    update p;
    Assert.isTrue(confirmer.isConfirmed(),
      'Your code was not hit when AverageRating__c changed');
    Database.rollback(sp);
  }

  public void whatIsATrigger() {
    ApexTrigger bookTrigger = assertTriggerExists('BookTrigger');
    assertCodeBodyBulk(bookTrigger.Body, new Map<String, String> { 
        'stringhelloWorld=\'campapex\'' => '"BookTrigger" exists, but it ' +
          'does not contain a String named "helloWord" with a value of ' +
          '"Camp Apex"'
    });
  }

  private void clearConfirmer() {
    confirmer = null;
  }

  private static void assertCodeBodyBulk(String codeBody, 
    Map<String, String> searchStringToError) {
    codeBody = codeBody.deleteWhitespace();

    for (String searchString : searchStringToError.keySet()) {
      Assert.isTrue(codeBody.containsIgnoreCase(searchString),
        searchStringToError.get(searchString));
    }
  }

  private static ApexTrigger assertTriggerExists(String triggerName) {
    String errorMessageBase = 
      'Cannot find an Apex Trigger named "{0}"';
      List<ApexTrigger> foundTrigger = [SELECT Id, Body
                                        FROM ApexTrigger
                                        WHERE Name = :triggerName];
      if (foundTrigger.isEmpty()) {
        throw new CampApexTestException(String.format(errorMessageBase, 
          new List<String> { triggerName }));
      }
      return foundTrigger[0];
  }

  public static void confirmChallange() {
    confirmer.isComplete = true;
  }

  public static void confirmChallange(String logString) {
    confirmer.logStrings.add(logString);
  }

  public class CampApexTestException extends Exception {}

  public class ChallangeConfirmation {
    private Set<String> logStrings;
    private Boolean isComplete;

    public challangeConfirmation() {
      isComplete = false;
      logStrings = new Set<String>();
    }
    
    public void clearConfirmation() {
      isComplete = false;
    }

    public Boolean isConfirmed() {
      return isComplete;
    }
  }
}