public class Utils {
  public class ChallangeConfirmation {
    private String challangeName;
    private Set<String> logStrings;
    private Boolean isComplete;

    public challangeConfirmation(String challangeName) {
      this.challangeName = challangeName;
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