public class CampApexTests {
  public static void whatIsATrigger() {
    ApexTrigger bookTrigger = assertTriggerExists('BookTrigger');
    assertCodeBodyBulk(bookTrigger.Body, new Map<String, String> { 
        'stringhelloWorld=\'campapex\'' => '"BookTrigger" exists, but it ' +
          'does not contain a String named "helloWord" with a value of ' +
          '"Camp Apex"'
    });
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

  private static void assertCodeBodyBulk(String codeBody, 
    Map<String, String> searchStringToError) {

    codeBody = codeBody.deleteWhitespace();
    for (String searchString : searchStringToError.keySet()) {
      if (!codeBody.containsIgnoreCase(searchString)) {
        throw new CampApexTestException(searchStringToError.get(searchString));
      }
    }
  }

  public class CampApexTestException extends Exception {}
}