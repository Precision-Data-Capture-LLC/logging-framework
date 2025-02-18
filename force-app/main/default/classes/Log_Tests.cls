/**
 * @description       :
 * @author            : agentgill
 * @group             :
 * @last modified on  : 03-26-2021
 * @last modified by  : agentgill
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   03-26-2021   agentgill   Initial Version
 **/
@isTest
private class Log_Tests {
  @isTest
  static void testDirectPublishMethodsPositive() {
    Test.startTest();
    Log.get().publish('This is a test');
    Log.get().publish(new DMLException('hi from exception land'));
    Test.stopTest();
    Test.getEventBus().deliver();
    String currentRequestId = Request.getCurrent().getRequestId();
    Quiddity currentQuiddity = Request.getCurrent().getQuiddity();
    List<LogEvent__c> events = [
      SELECT Id, Request_Id__c, Quiddity__c, Log_Data__c, Severity__c
      FROM LogEvent__c
      ORDER BY Severity__c
    ];
    System.assertEquals(
      2,
      events.size(),
      'expected to find only a single event'
    );

    for (LogEvent__c logEvt : events) {
      System.assertEquals(
        currentRequestId,
        logEvt.Request_Id__c,
        'Expected the reuqest id to have been logged'
      );
      System.assertEquals(
        currentQuiddity.name(),
        logEvt.Quiddity__c,
        'Expected quiddity on log message to match apex test context'
      );
      System.assert(
        new Set<String>{
            Quiddity.RUNTEST_ASYNC.name(),
            Quiddity.RUNTEST_DEPLOY.name(),
            Quiddity.RUNTEST_SYNC.name()
          }
          .contains(logEvt.Quiddity__c),
        'Expected quiddity to be one of the apex test types, found: ' +
        logEvt.Quiddity__c
      );
    }
  }

  @isTest
  static void testLogMultipleItemPositive() {
    Log logger = Log.get();
    Test.startTest();
    logger.add('testing add string method');
    logger.add('Testing 123', LogSeverity.WARN);
    logger.add(new DMLException('hi from exception land'));
    logger.add(new DMLException('meh'), LogSeverity.DEBUG);
    logger.publish();
    Test.stopTest();
    // Platform Events require this to push the event in a test env
    Test.getEventBus().deliver();

    String currentRequestId = Request.getCurrent().getRequestId();
    //this can't be hard-coded since apex test runs have multiple possible quiddity values
    Quiddity currentQuiddity = Request.getCurrent().getQuiddity();

    List<LogEvent__c> events = [
      SELECT Id, Request_Id__c, Quiddity__c, Log_Data__c, Severity__c
      FROM LogEvent__c
      ORDER BY Severity__c
    ];

    System.assertEquals(4, events.size(), 'Expected to find 3 records');

    for (LogEvent__c logEvt : events) {
      System.assertEquals(
        currentRequestId,
        logEvt.Request_Id__c,
        'Expected the reuqest id to have been logged'
      );
      System.assertEquals(
        currentQuiddity.name(),
        logEvt.Quiddity__c,
        'Expected quiddity on log message to match apex test context'
      );
      System.assert(
        new Set<String>{
            Quiddity.RUNTEST_ASYNC.name(),
            Quiddity.RUNTEST_DEPLOY.name(),
            Quiddity.RUNTEST_SYNC.name()
          }
          .contains(logEvt.Quiddity__c),
        'Expected quiddity to be one of the apex test types, found: ' +
        logEvt.Quiddity__c
      );

      //debug info warn error - proposed
    }

    System.assert(
      events[0].Log_Data__c.split('\n')[0]
        .containsIgnoreCase('Exception: [System.DMLException] meh'),
      'Expected the log data to contain [System.DMLException] meh'
    );
    //System.AssertException: Assertion Failed: Expected: Exception: [System.DmlException] meh , Actual: Exception: [System.DMLException] meh
  }

  /**
   * @description New Apex Test for Add with Salesforce Record Id
   * @author agentgill | 03-26-2021
   **/
  @isTest
  private static void testLogEventWithSalesforceId() {
    LogEvent__c testEvt = new LogEvent__c(
      Request_Id__c = 'TST',
      Log_Data__c = 'TST'
    );
    insert testEvt;
    Test.startTest();
    Log logger = Log.get();

    logger.add('Testing 123', LogSeverity.WARN, 'TestSource', testEvt.Id);
    logger.publish();
    Test.stopTest();
    // Platform Events require this to push the event in a test env
    Test.getEventBus().deliver();

    String currentRequestId = Request.getCurrent().getRequestId();
    //this can't be hard-coded since apex test runs have multiple possible quiddity values
    Quiddity currentQuiddity = Request.getCurrent().getQuiddity();

    List<LogEvent__c> events = [
      SELECT Id, Request_Id__c, Quiddity__c, Log_Data__c, Severity__c
      FROM LogEvent__c
      ORDER BY Severity__c
    ];

    System.assertEquals(2, events.size(), 'Expected to find 2 records');
  }

  /**
   * @description New Apex Test for Add with Source
   * @author agentgill | 03-26-2021
   **/
  @isTest
  private static void testLogEventWithSource() {
    LogEvent__c testEvt = new LogEvent__c(
      Request_Id__c = 'TST',
      Log_Data__c = 'TST'
    );
    insert testEvt;
    Test.startTest();
    Log logger = Log.get();

    logger.add('Testing 123', LogSeverity.WARN, 'TestSource');
    logger.publish();
    Test.stopTest();
    // Platform Events require this to push the event in a test env
    Test.getEventBus().deliver();

    String currentRequestId = Request.getCurrent().getRequestId();
    //this can't be hard-coded since apex test runs have multiple possible quiddity values
    Quiddity currentQuiddity = Request.getCurrent().getQuiddity();

    List<LogEvent__c> events = [
      SELECT Id, Request_Id__c, Quiddity__c, Log_Data__c, Severity__c
      FROM LogEvent__c
      ORDER BY Severity__c
    ];

    System.assertEquals(2, events.size(), 'Expected to find 2 records');
  }
}
