/**
 * @description A class for automatically attaching metadata to log messages
 * like Quiddity and RequestID
 */
public inherited sharing class LogMessage {
  private static final String EXCEPTION_STRING_FORMAT = 'Exception: [{0}] {1} \n StackTrace: {2}';

  /**
   * @description public read only property for the request ID. Privately set.
   */
  public String requestId {
    get {
      if (requestId == null) {
        requestId = Request.getCurrent().getRequestId();
      }
      return requestId;
    }
    private set;
  }

  /**
   * @description Public read only property for quiddity. Privately set.
   */
  public Quiddity quiddity {
    get {
      if (quiddity == null) {
        quiddity = Request.getCurrent().getQuiddity();
      }
      return quiddity;
    }
    private set;
  }

  /**
   * @description Public message property.
   */
  public String message { get; set; }

  /**
   * @description Public severity property.
   */
  public LogSeverity severity { get; set; }

  /**
   * @description Public source property.
   */
  public String source { get; set; }

  /**
   * @description Public source property.
   */
  public String sfdcrecordid { get; set; }

  /**
   * @description converts this object to an event for publishing
   * @return      `SObject`
   */
  public SObject toEvent() {
    return new Log__e(
      Log_Message__c = this.message,
      Request_Id__c = this.requestId,
      Quiddity__c = this.quiddity?.name(),
      Severity__c = this.severity?.name(),
      Source__c = this.source,
      Salesforce_Record_Id__c = this.sfdcrecordid
    );
  }

  /**
   * @description   Constructor accepting a message to log.
   * Severity is auto set to info
   * @param message
   */
  public LogMessage(String message) {
    this.message = message;
    this.severity = LogSeverity.INFO;
  }

  /**
   * @description Constructor accepting an exception object.
   * @param ex
   */
  public LogMessage(Exception ex) {
    this.message = String.format(
      EXCEPTION_STRING_FORMAT,
      new List<String>{
        ex.getTypeName(),
        ex.getMessage(),
        ex.getStackTraceString()
      }
    );
    this.severity = LogSeverity.ERROR;
  }
}
