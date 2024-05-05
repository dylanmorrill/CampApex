public class CampApexTests {
  private static ChallangeConfirmation confirmer;

  public CampApexTests() {
    confirmer = new ChallangeConfirmation();
  }

  public void triggerContextVariables() {
    System.Savepoint sp = Database.setSavepoint();
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