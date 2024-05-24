public class CampApexTests {
  private static ChallangeConfirmation confirmer;

  public CampApexTests() {
    confirmer = new ChallangeConfirmation();
  }

  public void performTestBeforeTriggers() {
    System.Savepoint sp = Database.setSavepoint();
    List<Author__c> authors = new List<Author__c> {
      new Author__c(Name = 'JK Rowling', Biography__c = 'test'),
      new Author__c(Name = 'Michael Lewis'),
      new Author__c(Name = 'Dan Appleman', Biography__c = 'test')
    };
    insert authors;
    authors = [SELECT Id, Name, BiographyLastUpdated__c
               FROM Author__c
               WHERE Id IN :authors];
    for (Author__c a : authors) {
      switch on a.Name {
        when 'Michael Lewis' {
          Assert.isNull(a.BiographyLastUpdated__c, 'Issue with insert ' +
            'trigger: Biography__c is null but BiographyLastUpdated__c was ' +
            'still populated');
        } when else {
          Assert.areEqual(Date.today(), a.BiographyLastUpdated__c,
            'Issue with insert trigger: Biography__c is populated but ' +
            'BiographyLastUpdated__c was not populated');
        }
      }
    }
    for (Author__c a : authors) {
      a.Biography__c = 'test1';
      a.BiographyLastUpdated__c = null;
    }
    update authors;
    authors = [SELECT Id, Name, BiographyLastUpdated__c
               FROM Author__c
               WHERE Id IN :authors];
    for (Author__c a : authors) {
      Assert.areEqual(Date.today(), a.BiographyLastUpdated__c,
        'Issue with update trigger: Biography__c is populated but' +
        'BiographyLastUpdated__c was not ' +
        'populated');
    }
    List<Book__c> books = new List<Book__c>();
    for (Integer i=0; i<20; i++) {
      books.add(new Book__c());
    }
    insert books;
    List<Publication__c> publications = new List<Publication__c>();
    Integer j = 0;
    for (Book__c b : books) {
      publications.add(new Publication__c(Book__c = b.Id, 
        Author__c = authors[Math.mod(j, 2)].Id));
      j++;
    }
    insert publications;
    try {
      delete authors;
    } catch (DmlException e) {
      Assert.areEqual(2, e.getNumDml(), 'Issue with delete trigger: ' +
        'expected 2 of 3 records to be blocked from deletion. Actual number ' +
        'blocked: ' + e.getNumDml());
      for (Integer i=0; i<2; i++) {
        Assert.areEqual(e.getDmlMessage(i), 
          'Authors with Publications cannot be deleted',
          'Issue with delete trigger: an error was thrown but the message was "' +
          e.getDmlMessage(i) + '" not "Authors with Publications cannot be ' +
          'deleted"');
      }
    }
    Integer currentQueries = Limits.getQueries();
    try {
      delete authors[2];
    } catch (Exception e) {
      String exceptionMessage = e.getDmlMessage(0);
      Boolean isTestedException 
        = exceptionMessage == 'Authors with Publications cannot be deleted';
      Assert.fail('Issue with delete trigger: '+
        'Tried to delete an Author without any Books but was ' +
        'blocked by ' + (isTestedException ? 'your trigger' : 
          'this error: ' + e.getDmlMessage(0)));
    }
    currentQueries -= Limits.getQueries();
    if (currentQueries > 0) {
      Assert.areEqual(1, Limits.getQueries() - currentQueries, 
        'You used more than one query');
    }
    Database.rollback(sp);
  }

  public void performTestBulkificationExecutionContext() {
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
    Database.rollback(sp);
  }

  public void performTestOrderExecutionTriggerHandlers() {
    String publisherTriggerBody = assertTriggerExists('PublisherTrigger').Body;
    String publisherHandlerBody = 
      assertApexClassExists('PublisherTriggerHandler').Body;
    String publicationTriggerBody = 
      assertTriggerExists('PublicationTrigger').Body;
    String publicationHandlerBody =
      assertApexClassExists('PublicationTriggerHandler').Body;
    assertCodeBodyBulk(publisherTriggerBody, new Map<String, String> { 
        'newPublisherTriggerHandler().execute();' => 'Cannot find code ' +
          'that creates a new PublisherTriggerHandler object and calls its ' +
          'execute method'
    });
    assertCodeBodyBulk(publisherHandlerBody, new Map<String, String> { 
      'switchonTrigger.OperationType' => 'Cannot find switch statement for ' +
        'Trigger.OperationType',
      'whenBEFORE_INSERT{' => 'The switch statement in the ' +
        'PublisherTriggerHandler is missing the BEFORE_INSERT operation',
      'whenBEFORE_UPDATE{' => 'The switch statement in the ' +
        'PublisherTriggerHandler is missing the BEFORE_UPDATE operation',
      'whenBEFORE_DELETE{' => 'The switch statement in the ' +
        'PublisherTriggerHandler is missing the BEFORE_DELETE operation',
      'whenAFTER_INSERT{' => 'The switch statement in the ' +
        'PublisherTriggerHandler is missing the AFTER_INSERT operation',
      'whenAFTER_UPDATE{' => 'The switch statement in the ' +
        'PublisherTriggerHandler is missing the AFTER_UPDATE operation',
      'whenAFTER_DELETE{' => 'The switch statement in the ' +
        'PublisherTriggerHandler is missing the AFTER_DELETE operation',
      'whenAFTER_UNDELETE{' => 'The switch statement in the ' +
        'PublisherTriggerHandler is missing the AFTER_UNDELETE operation'
    });
    assertCodeBodyBulk(publicationTriggerBody, new Map<String, String> { 
      'newPublicationTriggerHandler().execute();' => 'Cannot find code ' +
        'that creates a new PublicationTriggerHandler object and calls its ' +
        'execute method'
    });
    assertCodeBodyBulk(publicationHandlerBody, new Map<String, String> { 
      'switchonTrigger.OperationType' => 'Cannot find switch statement for ' +
        'Trigger.OperationType',
      'whenBEFORE_INSERT{' => 'The switch statement in the ' +
        'PublicationTriggerHandler is missing the BEFORE_INSERT operation',
      'whenBEFORE_UPDATE{' => 'The switch statement in the ' +
        'PublicationTriggerHandler is missing the BEFORE_UPDATE operation',
      'whenBEFORE_DELETE{' => 'The switch statement in the ' +
        'PublicationTriggerHandler is missing the BEFORE_DELETE operation',
      'whenAFTER_INSERT{' => 'The switch statement in the ' +
        'PublicationTriggerHandler is missing the AFTER_INSERT operation',
      'whenAFTER_UPDATE{' => 'The switch statement in the ' +
        'PublicationTriggerHandler is missing the AFTER_UPDATE operation',
      'whenAFTER_DELETE{' => 'The switch statement in the ' +
        'PublicationTriggerHandler is missing the AFTER_DELETE operation',
      'whenAFTER_UNDELETE{' => 'The switch statement in the ' +
        'PublicationTriggerHandler is missing the AFTER_UNDELETE operation'
    });
  }

  public void performTestTriggerContextVariables() {
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

  public void performTestWhatIsATrigger() {
    String bookTriggerBody = assertTriggerExists('BookTrigger').Body;
    assertCodeBodyBulk(bookTriggerBody, new Map<String, String> { 
        'StringHelloWorld=\'CampApex\'' => '"BookTrigger" exists, but it ' +
          'does not contain a String named "helloWord" with a value of ' +
          '"Camp Apex"'
    });
  }

  private ApexClass assertApexClassExists(String apexClassName) {
    String errorMessageBase = 
      'Cannot find an Apex Class named "{0}"';
      List<ApexClass> foundApexClass = [SELECT Id, Body
                                      FROM ApexClass
                                      WHERE Name = :apexClassName];
      if (foundApexClass.isEmpty()) {
        throw new CampApexTestException(String.format(errorMessageBase, 
          new List<String> { apexClassName }));
      }
      return foundApexClass[0];
  }

  private void assertCodeBodyBulk(String codeBody, 
    Map<String, String> searchStringToError) {
      
    codeBody = codeBody.deleteWhitespace();
    for (String searchString : searchStringToError.keySet()) {
      Assert.isTrue(codeBody.containsIgnoreCase(searchString),
        searchStringToError.get(searchString));
    }
  }

  private ApexTrigger assertTriggerExists(String triggerName) {
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

  private void clearConfirmer() {
    confirmer = null;
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