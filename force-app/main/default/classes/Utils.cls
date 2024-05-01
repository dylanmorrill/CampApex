public class Utils {
  public static ChallangeConfirmation confirmer;

  public static void confirmChallange(String challangeName) {
    confirmer.isComplete = true;
  }

  public static ChallangeConfirmation createConfirmer(String challangeName) {
    return new ChallangeConfirmation(challangeName);
  }

  public class ChallangeConfirmation {
    public String challangeName;
    public Boolean isComplete;

    public challangeConfirmation(String challangeName) {
      this.challangeName = challangeName;
      isComplete = false;
    }
    
    public void clearConfirmation() {
      isComplete = false;
    }

    public Boolean isConfirmed() {
      return isComplete;
    }
  }
}