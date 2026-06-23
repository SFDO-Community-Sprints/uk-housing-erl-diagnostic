---
hide:
  - path
---

# TriggerHandlerTest Class

`ISTEST`

## Class Diagram

```mermaid
graph TD
  TriggerHandlerTest["TriggerHandlerTest"]:::mainApexClass
  click TriggerHandlerTest "/objects/TriggerHandlerTest/"
  MockTriggerHandler["MockTriggerHandler"]:::apexClass
  click MockTriggerHandler "/apex/MockTriggerHandler/"
  TriggerHandler["TriggerHandler"]:::apexClass
  click TriggerHandler "/apex/TriggerHandler/"
  TriggerHandlerException["TriggerHandlerException"]:::apexClass
  click TriggerHandlerException "/apex/TriggerHandlerException/"

  TriggerHandlerTest --> MockTriggerHandler
  TriggerHandlerTest --> TriggerHandler
  TriggerHandlerTest --> TriggerHandlerException


  MockTriggerHandler --> TriggerHandler
  TriggerHandler --> TriggerHandlerException
  TriggerHandlerException --> TriggerHandler

classDef apexClass fill:#FFF4C2,stroke:#CCAA00,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef apexTestClass fill:#F5F5F5,stroke:#999999,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef mainApexClass fill:#FFB3B3,stroke:#A94442,stroke-width:4px,rx:14px,ry:14px,shadow:drop,color:#333,font-weight:bold;

linkStyle 0,1,2 stroke:#4C9F70,stroke-width:4px;
linkStyle 3,4,5 stroke:#A6A6A6,stroke-width:2px;
```

<!-- Apex description -->

## Apex Code

```java
@isTest(seealldata=false)
private class TriggerHandlerTest {
	
	/**
	* @description test the getName method returns the trigger handlers class name as a string.
	**/
	private static testMethod void testGetName(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		
		System.assertEquals('MockTriggerHandler',testTriggerHandler.getName(),'The name should match the class name.');
	}
	
	/**
	* @description test the bypass method with the MockTriggerHandler to ensure that the handler
	*			   methods are bypassed as expected.
	**/
	private static testMethod void testBypass_AllContexts(){
		TriggerHandler.bypass('MockTriggerHandler');
		
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_INSERT);
		testTriggerHandler.run();
		
		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler'),'The testTriggerHandler should be bypassed.');
		
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_UPDATE);
		testTriggerHandler.run();
		
		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler'),'The testTriggerHandler should be bypassed.');
		
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_DELETE);
		testTriggerHandler.run();
		
		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler'),'The testTriggerHandler should be bypassed.');
		
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.AFTER_INSERT);
		testTriggerHandler.run();
		
		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler'),'The testTriggerHandler should be bypassed.');
		
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.AFTER_UPDATE);
		testTriggerHandler.run();
		
		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler'),'The testTriggerHandler should be bypassed.');
		
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.AFTER_DELETE);
		testTriggerHandler.run();
		
		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler'),'The testTriggerHandler should be bypassed.');
		
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.AFTER_UNDELETE);
		testTriggerHandler.run();
		
		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler'),'The testTriggerHandler should be bypassed.');
	}
	
	/**
	* @description test the bypass method with an empty handler name to ensure that a
	*			   TriggerHandlerException is thrown as expected.
	**/
	private static testMethod void testBypass_EmptyHandlerName(){
		try{
			TriggerHandler.bypass('');
			System.assert(false);
		}catch(TriggerHandlerException ex){
			System.assert(true);
		}
	}
	
	/**
	* @description test the bypass method with a null handler name to ensure that a
	*			   TriggerHandlerException is thrown as expected.
	**/
	private static testMethod void testBypass_NullHandlerName(){
		try{
			String handlerName;
			TriggerHandler.bypass(handlerName);
			System.assert(false);
		}catch(TriggerHandlerException ex){
			System.assert(true);
		}
	}
	
	/**
	* @description test the bypass method with an invalid handler name to ensure that a
	*			   TriggerHandlerException is thrown as expected. Since only a class which
	*			   extends TriggerHandler can be bypassed.
	**/
	private static testMethod void testBypass_InvalidHandlerName(){
		try{
			TriggerHandler.bypass('TriggerHandlerException');
			System.assert(false);
		}catch(TriggerHandlerException ex){
			System.assert(true);
		}
	}
	
	/**
	* @description test the bypass method with the MockTriggerHandler and a single context to ensure
	*			   that the handler methods are bypassed for the given context as expected.
	**/
	private static testMethod void testBypass_SingleContext(){
		TriggerHandler.bypass('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_INSERT);
		
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_INSERT);
		testTriggerHandler.run();
		
		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler'),'The full testTriggerHandler should not be bypassed.');
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_INSERT),'The before insert of the testTriggerHandler should be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_UPDATE),'The before update of the testTriggerHandler should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_DELETE),'The before delete of the testTriggerHandler should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_INSERT),'The after insert of the testTriggerHandler should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_UPDATE),'The after update of the testTriggerHandler should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_DELETE),'The after delete of the testTriggerHandler should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_UNDELETE),'The after undelete of the testTriggerHandler should not be bypassed.');
	}
	
	/**
	* @description test the bypass method with the MockTriggerHandler two contexts to ensure
	*			   that the handler methods are bypassed for the given contexts as expected.
	**/
	private static testMethod void testBypass_TwoContexts(){
		Set<TriggerHandler.TriggerContext> contextsForBypass = new Set<TriggerHandler.TriggerContext>{
																			TriggerHandler.TriggerContext.BEFORE_INSERT,
																			TriggerHandler.TriggerContext.BEFORE_UPDATE
																		};
																		
		TriggerHandler.bypass('MockTriggerHandler',contextsForBypass);
		
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_INSERT);
		testTriggerHandler.run();
		
		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
		
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_UPDATE);
		testTriggerHandler.run();
		
		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
		
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.AFTER_INSERT);
		testTriggerHandler.run();
		
		System.assertNotEquals(null,testTriggerHandler.triggerContextCalled,'Trigger context method should be called.');
		System.assertEquals('afterInsert',testTriggerHandler.triggerContextCalled,'After Insert Trigger context method should be called.');
		
		
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler'),'The full testTriggerHandler should not be bypassed.');
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_INSERT),'The before insert of the testTriggerHandler should be bypassed.');
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_UPDATE),'The before update of the testTriggerHandler should be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_DELETE),'The before delete of the testTriggerHandler should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_INSERT),'The after insert of the testTriggerHandler should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_UPDATE),'The after update of the testTriggerHandler should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_DELETE),'The after delete of the testTriggerHandler should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_UNDELETE),'The after undelete of the testTriggerHandler should not be bypassed.');
	}
	
	/**
	* @description test the bypass method with the MockTriggerHandler with additional context for
	*			   bypass to ensure that the handler methods are bypassed for the given contexts as
	*			   expected.
	**/
	private static testMethod void testBypass_AdditonalContext(){
		Set<TriggerHandler.TriggerContext> contextsForBypass = new Set<TriggerHandler.TriggerContext>{
																			TriggerHandler.TriggerContext.BEFORE_INSERT,
																			TriggerHandler.TriggerContext.BEFORE_UPDATE
																		};
																		
		TriggerHandler.bypass('MockTriggerHandler',contextsForBypass);
		
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_INSERT);
		testTriggerHandler.run();
		
		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
		
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_UPDATE);
		testTriggerHandler.run();
		
		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
		
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.AFTER_INSERT);
		testTriggerHandler.run();
		
		System.assertNotEquals(null,testTriggerHandler.triggerContextCalled,'Trigger context method should be called.');
		System.assertEquals('afterInsert',testTriggerHandler.triggerContextCalled,'After Insert Trigger context method should be called.');
		
		
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler'),'The full testTriggerHandler should not be bypassed.');
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_INSERT),'The before insert of the testTriggerHandler should be bypassed.');
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_UPDATE),'The before update of the testTriggerHandler should be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_DELETE),'The before delete of the testTriggerHandler should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_INSERT),'The after insert of the testTriggerHandler should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_UPDATE),'The after update of the testTriggerHandler should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_DELETE),'The after delete of the testTriggerHandler should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_UNDELETE),'The after undelete of the testTriggerHandler should not be bypassed.');
		
		//Add new bypass to existing
		TriggerHandler.bypass('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_INSERT);
		
		testTriggerHandler.triggerContextCalled = null; //reset trigger context called to null
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_INSERT);
		testTriggerHandler.run();
		
		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
		
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_UPDATE);
		testTriggerHandler.run();
		
		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
		
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.AFTER_INSERT);
		testTriggerHandler.run();
		
		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
		
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.AFTER_UPDATE);
		testTriggerHandler.run();
		
		System.assertNotEquals(null,testTriggerHandler.triggerContextCalled,'Trigger context method should be called.');
		System.assertEquals('afterUpdate',testTriggerHandler.triggerContextCalled,'After Update Trigger context method should be called.');
		
		
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler'),'The full testTriggerHandler should not be bypassed.');
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_INSERT),'The before insert of the testTriggerHandler should be bypassed.');
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_UPDATE),'The before update of the testTriggerHandler should be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_DELETE),'The before delete of the testTriggerHandler should not be bypassed.');
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_INSERT),'The after insert of the testTriggerHandler should be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_UPDATE),'The after update of the testTriggerHandler should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_DELETE),'The after delete of the testTriggerHandler should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.AFTER_UNDELETE),'The after undelete of the testTriggerHandler should not be bypassed.');
		
	}
	
	/**
	* @description test the isBypassed method to ensure we can identify if a trigger handler has
	*			   been bypassed.
	**/
	private static testMethod void testIsBypassed(){
		TriggerHandler.bypass('MockTriggerHandler');
		
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler'),'The testTriggerHandler should be bypassed.');
	}
	
	/**
	* @description test the isBypassed method with an empty handler name to ensure that a
	*			   TriggerHandlerException is thrown as expected.
	**/
	private static testMethod void testIsBypassed_EmptyHandlerName(){
		try{
			TriggerHandler.isBypassed('');
			System.assert(false);
		}catch(TriggerHandlerException ex){
			System.assert(true);
		}
	}
	
	/**
	* @description test the isBypassed method with a null handler name to ensure that a
	*			   TriggerHandlerException is thrown as expected.
	**/
	private static testMethod void testIsBypassed_NullHandlerName(){
		try{
			String handlerName;
			TriggerHandler.isBypassed(handlerName);
			System.assert(false);
		}catch(TriggerHandlerException ex){
			System.assert(true);
		}
	}
	
	/**
	* @description test the isBypassed method with an invalid handler name to ensure that a
	*			   TriggerHandlerException is thrown as expected. Since only a class which
	*			   extends TriggerHandler can be bypassed.
	**/
	private static testMethod void testIsBypassed_InvalidHandlerName(){
		try{
			TriggerHandler.isBypassed('TriggerHandlerException');
			System.assert(false);
		}catch(TriggerHandlerException ex){
			System.assert(true);
		}
	}
	
	/**
	* @description test the clearBypass method with the MockTriggerHandler to ensure that the handler
	*			   methods are cleared from the bypassed list as expected.
	**/
	private static testMethod void testClearBypass_AllContexts(){
		TriggerHandler.bypass('MockTriggerHandler');
		
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler'),'The testTriggerHandler should be bypassed.');
		
		TriggerHandler.clearBypass('MockTriggerHandler');
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_INSERT);
		testTriggerHandler.run();
		
		System.assertEquals('beforeInsert',testTriggerHandler.triggerContextCalled,'The beforeInsert trigger context method should be called.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler'),'The testTriggerHandler should not be bypassed.');
	}
	
	/**
	* @description test the clearBypass method with the MockTriggerHandler and a given context to
	*			   ensure that the handler methods for the given context are cleared from the
	*			   bypassed list as expected.
	**/
	private static testMethod void testClearBypass_SingleContext(){
		TriggerHandler.bypass('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_INSERT);
		
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_INSERT),'The testTriggerHandler beforeInsert context should be bypassed.');
		
		TriggerHandler.clearBypass('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_INSERT);
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_INSERT);
		testTriggerHandler.run();
		
		System.assertEquals('beforeInsert',testTriggerHandler.triggerContextCalled,'The beforeInsert trigger context method should be called.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_INSERT),'The testTriggerHandler beforeInsert context should not be bypassed.');
	}
	
	/**
	* @description test the clearBypass method with the MockTriggerHandler and given contexts to
	*			   ensure that the handler methods for the given contexts are cleared from the
	*			   bypassed list as expected.
	**/
	private static testMethod void testClearBypass_TwoContexts(){
		Set<TriggerHandler.TriggerContext> contextsForBypass = new Set<TriggerHandler.TriggerContext>{
																			TriggerHandler.TriggerContext.BEFORE_INSERT,
																			TriggerHandler.TriggerContext.BEFORE_UPDATE
																		};
		TriggerHandler.bypass('MockTriggerHandler',contextsForBypass);
		
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler',contextsForBypass),'The testTriggerHandler beforeInsert & beforeUpdate contexts should be bypassed.');
		
		TriggerHandler.clearBypass('MockTriggerHandler',contextsForBypass);
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_INSERT);
		testTriggerHandler.run();
		
		System.assertEquals('beforeInsert',testTriggerHandler.triggerContextCalled,'The beforeInsert trigger context method should be called.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',contextsForBypass),'The testTriggerHandler beforeInsert & beforeUpdate contexts should not be bypassed.');
	}
	
	/**
	* @description test the clearBypass method with the MockTriggerHandler and a given context to
	*			   ensure that when all context are cleared the trigger bypass is cleared.
	**/
	private static testMethod void testClearBypass_RemoveAllContexts(){
		TriggerHandler.bypass('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_INSERT);
		
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_INSERT),'The testTriggerHandler beforeInsert context should be bypassed.');
		
		TriggerHandler.clearBypass('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_INSERT);
		
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler',TriggerHandler.TriggerContext.BEFORE_INSERT),'The testTriggerHandler beforeInsert context should not be bypassed.');
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler'),'The testTriggerHandler should not be bypassed.');
	}
	
	/**
	* @description test the clearBypass method with an empty handler name to ensure that a
	*			   TriggerHandlerException is thrown as expected.
	**/
	private static testMethod void testClearBypass_EmptyHandlerName(){
		try{
			TriggerHandler.clearBypass('');
			System.assert(false);
		}catch(TriggerHandlerException ex){
			System.assert(true);
		}
	}
	
	/**
	* @description test the clearBypass method with a null handler name to ensure that a
	*			   TriggerHandlerException is thrown as expected.
	**/
	private static testMethod void testClearBypass_NullHandlerName(){
		try{
			String handlerName;
			TriggerHandler.clearBypass(handlerName);
			System.assert(false);
		}catch(TriggerHandlerException ex){
			System.assert(true);
		}
	}
	
	/**
	* @description test the clearBypass method with an invalid handler name to ensure that a
	*			   TriggerHandlerException is thrown as expected. Since only a class which
	*			   extends TriggerHandler can be bypassed.
	**/
	private static testMethod void testClearBypass_InvalidHandlerName(){
		try{
			TriggerHandler.clearBypass('TriggerHandlerException');
			System.assert(false);
		}catch(TriggerHandlerException ex){
			System.assert(true);
		}
	}
	
	/**
	* @description test the clearAllBypasses method with the MockTriggerHandler and TriggerHandler
	*			   to ensure that all the handlers are cleared from the bypassed list as expected.
	**/
	private static testMethod void testClearAllBypasses(){
		TriggerHandler.bypass('MockTriggerHandler');
		TriggerHandler.bypass('TriggerHandler');
		
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler'),'The MockTriggerHandler should be bypassed.');
		
		System.assertEquals(true,TriggerHandler.isBypassed('TriggerHandler'),'The TriggerHandler should be bypassed.');
		
		TriggerHandler.clearAllBypasses();
		
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler'),'The MockTriggerHandler should not be bypassed.');
		
		System.assertEquals(false,TriggerHandler.isBypassed('TriggerHandler'),'The TriggerHandler should not be bypassed.');
	}
	
	/**
	* @description test the run method with the before insert trigger context using the
	*			   MockTriggerHandler to ensure that the correct trigger context method is called.
	**/
	private static testMethod void testRun_BeforeInsert(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_INSERT);
		testTriggerHandler.run();
		
		System.assertEquals('beforeInsert',testTriggerHandler.triggerContextCalled,'The beforeInsert trigger context method should be called.');
	}
	
	/**
	* @description test the run method with the before update trigger context using the
	*			   MockTriggerHandler to ensure that the correct trigger context method is called.
	**/
	private static testMethod void testRun_BeforeUpdate(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_UPDATE);
		testTriggerHandler.run();
		
		System.assertEquals('beforeUpdate',testTriggerHandler.triggerContextCalled,'The beforeUpdate trigger context method should be called.');
	}
	
	/**
	* @description test the run method with the before delete trigger context using the
	*			   MockTriggerHandler to ensure that the correct trigger context method is called.
	**/
	private static testMethod void testRun_BeforeDelete(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_DELETE);
		testTriggerHandler.run();
		
		System.assertEquals('beforeDelete',testTriggerHandler.triggerContextCalled,'The beforeDelete trigger context method should be called.');
	}
	
	/**
	* @description test the run method with the after insert trigger context using the
	*			   MockTriggerHandler to ensure that the correct trigger context method is called.
	**/
	private static testMethod void testRun_AfterInsert(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.AFTER_INSERT);
		testTriggerHandler.run();
		
		System.assertEquals('afterInsert',testTriggerHandler.triggerContextCalled,'The afterInsert trigger context method should be called.');
	}
	
	/**
	* @description test the run method with the after update trigger context using the
	*			   MockTriggerHandler to ensure that the correct trigger context method is called.
	**/
	private static testMethod void testRun_AfterUpdate(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.AFTER_UPDATE);
		testTriggerHandler.run();
		
		System.assertEquals('afterUpdate',testTriggerHandler.triggerContextCalled,'The afterUpdate trigger context method should be called.');
	}
	
	/**
	* @description test the run method with the after delete trigger context using the
	*			   MockTriggerHandler to ensure that the correct trigger context method is called.
	**/
	private static testMethod void testRun_AfterDelete(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.AFTER_DELETE);
		testTriggerHandler.run();
		
		System.assertEquals('afterDelete',testTriggerHandler.triggerContextCalled,'The afterDelete trigger context method should be called.');
	}
	
	/**
	* @description test the run method with the after undelete trigger context using the
	*			   MockTriggerHandler to ensure that the correct trigger context method is called.
	**/
	private static testMethod void testRun_AfterUndelete(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.AFTER_UNDELETE);
		testTriggerHandler.run();
		
		System.assertEquals('afterUndelete',testTriggerHandler.triggerContextCalled,'The afterUndelete trigger context method should be called.');
	}
	
	/**
	* @description test the run method with no trigger context using the MockTriggerHandler to
	*			   ensure that no trigger context method is called.
	**/
	private static testMethod void testRun_NoContext(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		
		try{
			testTriggerHandler.run();
			System.assert(false);
		}catch(TriggerHandlerException ex){
			System.assert(true);
		}

		System.assertEquals(null,testTriggerHandler.triggerContextCalled,'No trigger context method should be called.');
	}
	
	/**
	* @description test the validateIsTriggerHandler method with the MockTriggerHandler to ensure
	*			   that the handler is recognised as a valid TriggerHandler.
	**/
	private static testMethod void testValidateIsTriggerHandler(){
		try{
			TriggerHandler.validateIsTriggerHandler('MockTriggerHandler');
			System.assert(true);
		}catch(TriggerHandlerException ex){
			System.assert(false);
		}catch(Exception ex){
			System.assert(false);
		}
	}
	
	/**
	* @description test the validateIsTriggerHandler method with an empty handler name to ensure
	*			   that a TriggerHandlerException is thrown as expected.
	**/
	private static testMethod void testValidateIsTriggerHandler_EmptyHandlerName(){
		try{
			TriggerHandler.validateIsTriggerHandler('');
			System.assert(false);
		}catch(TriggerHandlerException ex){
			System.assert(true);
		}
	}
	
	/**
	* @description test the validateIsTriggerHandler method with an null handler name to ensure
	*			   that a TriggerHandlerException is thrown as expected.
	**/
	private static testMethod void testValidateIsTriggerHandler_NullHandlerName(){
		try{
			String handlerName;
			TriggerHandler.validateIsTriggerHandler(handlerName);
			System.assert(false);
		}catch(TriggerHandlerException ex){
			System.assert(true);
		}
	}
	
	/**
	* @description test the validateIsTriggerHandler method with an invalid handler name to ensure
	*			   that a TriggerHandlerException is thrown as expected. Since only a class which
	*			   extends TriggerHandler can be bypassed.
	**/
	private static testMethod void testValidateIsTriggerHandler_InvalidHandlerName(){
		try{
			TriggerHandler.validateIsTriggerHandler('TriggerHandlerException');
			System.assert(false);
		}catch(TriggerHandlerException ex){
			System.assert(true);
		}
	}
	
	/**
	* @description test the isValid method using the MockTriggerHandler to ensure that it returns 
	*			   true when the maxRecursion is null and the TriggerHandler is not bypassed.
	**/
	private static testMethod void testIsValid_MaxRecursionNullTriggerHandlerNotBypassed(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_INSERT);
		System.assertEquals(null,testTriggerHandler.maxRecursion);
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler'));
		
		System.assertEquals(true,testTriggerHandler.isValid(),'Should return true when maxRecursion is null and the TriggerHandler is not bypassed');
	}
	
	/**
	* @description test the isValid method using the MockTriggerHandler to ensure that it returns 
	*			   true when the maxRecursion is greater than the recursionCount and the TriggerHandler
	*			   is not bypassed.
	**/
	private static testMethod void testIsValid_MaxRecursionNotReachedTriggerHandlerNotBypassed(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_INSERT);
		testTriggerHandler.setMaxRecursion(3);
		
		System.assertEquals(3,testTriggerHandler.maxRecursion);
		System.assertEquals(0,testTriggerHandler.recursionCount);
		System.assertEquals(false,TriggerHandler.isBypassed('MockTriggerHandler'));
		
		System.assertEquals(true,testTriggerHandler.isValid(),'Should return true when maxRecursion is greater than the recursionCount and the TriggerHandler is not bypassed');
	}
	
	/**
	* @description test the isValid method using the MockTriggerHandler to ensure that it returns 
	*			   false when the recursionCount has reached maxRecursion.
	**/
	private static testMethod void testIsValid_MaxRecursionReached(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_INSERT);
		testTriggerHandler.setMaxRecursion(0);
		
		System.assertEquals(0,testTriggerHandler.maxRecursion);
		System.assertEquals(0,testTriggerHandler.recursionCount);
		
		System.assertEquals(false,testTriggerHandler.isValid(),'Should return false when maxRecursion is reached');
	}
	
	/**
	* @description test the isValid method using the MockTriggerHandler to ensure that it returns 
	*			   false when the TriggerHandler is bypassed.
	**/
	private static testMethod void testIsValid_TriggerHandlerBypassed(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_INSERT);
		TriggerHandler.bypass('MockTriggerHandler');
		
		System.assertEquals(true,TriggerHandler.isBypassed('MockTriggerHandler'));
		
		System.assertEquals(false,testTriggerHandler.isValid(),'Should return false when the TriggerHandler is bypassed');
	}
	
	/**
	* @description test the setTriggerContext method when no trigger has an active context.
	**/
	private static testMethod void testSetTriggerContext_NoContext(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext();
		
		System.assertEquals(false,testTriggerHandler.isExecuting,'IsExecuting should be false as there is no active trigger context');
		
		System.assertEquals(null,testTriggerHandler.context,'context should be null as there is no active trigger context');
	}
	
	/**
	* @description test the setTriggerContext method when null is passed as the trigger context.
	**/
	private static testMethod void testSetTriggerContext_NullContext(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		
		TriggerHandler.TriggerContext triggerContext;
		testTriggerHandler.setTriggerContext(triggerContext);
		
		System.assertEquals(false,testTriggerHandler.isExecuting,'IsExecuting should be false as there is no active trigger context');
		
		System.assertEquals(null,testTriggerHandler.context,'context should be null as there is no active trigger context');
	}
	
	/**
	* @description test the setTriggerContext method when trigger context is given.
	**/
	private static testMethod void testSetTriggerContext_WithContext(){
		MockTriggerHandler testTriggerHandler = new MockTriggerHandler();
		testTriggerHandler.setTriggerContext(TriggerHandler.TriggerContext.BEFORE_INSERT);
		
		System.assertEquals(true,testTriggerHandler.isExecuting,'IsExecuting should be true as there is an active trigger context');
		
		System.assertEquals(TriggerHandler.TriggerContext.BEFORE_INSERT,testTriggerHandler.context,'context should be the same as the contect passed in.');
	}
	
}
```

## Methods
### `testGetName()`

test the getName method returns the trigger handlers class name as a string.

#### Signature
```apex
private static testMethod void testGetName()
```

#### Return Type
**void**

---

### `testBypass_AllContexts()`

test the bypass method with the MockTriggerHandler to ensure that the handler 
methods are bypassed as expected.

#### Signature
```apex
private static testMethod void testBypass_AllContexts()
```

#### Return Type
**void**

---

### `testBypass_EmptyHandlerName()`

test the bypass method with an empty handler name to ensure that a 
TriggerHandlerException is thrown as expected.

#### Signature
```apex
private static testMethod void testBypass_EmptyHandlerName()
```

#### Return Type
**void**

---

### `testBypass_NullHandlerName()`

test the bypass method with a null handler name to ensure that a 
TriggerHandlerException is thrown as expected.

#### Signature
```apex
private static testMethod void testBypass_NullHandlerName()
```

#### Return Type
**void**

---

### `testBypass_InvalidHandlerName()`

test the bypass method with an invalid handler name to ensure that a 
TriggerHandlerException is thrown as expected. Since only a class which 
extends TriggerHandler can be bypassed.

#### Signature
```apex
private static testMethod void testBypass_InvalidHandlerName()
```

#### Return Type
**void**

---

### `testBypass_SingleContext()`

test the bypass method with the MockTriggerHandler and a single context to ensure 
that the handler methods are bypassed for the given context as expected.

#### Signature
```apex
private static testMethod void testBypass_SingleContext()
```

#### Return Type
**void**

---

### `testBypass_TwoContexts()`

test the bypass method with the MockTriggerHandler two contexts to ensure 
that the handler methods are bypassed for the given contexts as expected.

#### Signature
```apex
private static testMethod void testBypass_TwoContexts()
```

#### Return Type
**void**

---

### `testBypass_AdditonalContext()`

test the bypass method with the MockTriggerHandler with additional context for 
bypass to ensure that the handler methods are bypassed for the given contexts as 
expected.

#### Signature
```apex
private static testMethod void testBypass_AdditonalContext()
```

#### Return Type
**void**

---

### `testIsBypassed()`

test the isBypassed method to ensure we can identify if a trigger handler has 
been bypassed.

#### Signature
```apex
private static testMethod void testIsBypassed()
```

#### Return Type
**void**

---

### `testIsBypassed_EmptyHandlerName()`

test the isBypassed method with an empty handler name to ensure that a 
TriggerHandlerException is thrown as expected.

#### Signature
```apex
private static testMethod void testIsBypassed_EmptyHandlerName()
```

#### Return Type
**void**

---

### `testIsBypassed_NullHandlerName()`

test the isBypassed method with a null handler name to ensure that a 
TriggerHandlerException is thrown as expected.

#### Signature
```apex
private static testMethod void testIsBypassed_NullHandlerName()
```

#### Return Type
**void**

---

### `testIsBypassed_InvalidHandlerName()`

test the isBypassed method with an invalid handler name to ensure that a 
TriggerHandlerException is thrown as expected. Since only a class which 
extends TriggerHandler can be bypassed.

#### Signature
```apex
private static testMethod void testIsBypassed_InvalidHandlerName()
```

#### Return Type
**void**

---

### `testClearBypass_AllContexts()`

test the clearBypass method with the MockTriggerHandler to ensure that the handler 
methods are cleared from the bypassed list as expected.

#### Signature
```apex
private static testMethod void testClearBypass_AllContexts()
```

#### Return Type
**void**

---

### `testClearBypass_SingleContext()`

test the clearBypass method with the MockTriggerHandler and a given context to 
ensure that the handler methods for the given context are cleared from the 
bypassed list as expected.

#### Signature
```apex
private static testMethod void testClearBypass_SingleContext()
```

#### Return Type
**void**

---

### `testClearBypass_TwoContexts()`

test the clearBypass method with the MockTriggerHandler and given contexts to 
ensure that the handler methods for the given contexts are cleared from the 
bypassed list as expected.

#### Signature
```apex
private static testMethod void testClearBypass_TwoContexts()
```

#### Return Type
**void**

---

### `testClearBypass_RemoveAllContexts()`

test the clearBypass method with the MockTriggerHandler and a given context to 
ensure that when all context are cleared the trigger bypass is cleared.

#### Signature
```apex
private static testMethod void testClearBypass_RemoveAllContexts()
```

#### Return Type
**void**

---

### `testClearBypass_EmptyHandlerName()`

test the clearBypass method with an empty handler name to ensure that a 
TriggerHandlerException is thrown as expected.

#### Signature
```apex
private static testMethod void testClearBypass_EmptyHandlerName()
```

#### Return Type
**void**

---

### `testClearBypass_NullHandlerName()`

test the clearBypass method with a null handler name to ensure that a 
TriggerHandlerException is thrown as expected.

#### Signature
```apex
private static testMethod void testClearBypass_NullHandlerName()
```

#### Return Type
**void**

---

### `testClearBypass_InvalidHandlerName()`

test the clearBypass method with an invalid handler name to ensure that a 
TriggerHandlerException is thrown as expected. Since only a class which 
extends TriggerHandler can be bypassed.

#### Signature
```apex
private static testMethod void testClearBypass_InvalidHandlerName()
```

#### Return Type
**void**

---

### `testClearAllBypasses()`

test the clearAllBypasses method with the MockTriggerHandler and TriggerHandler 
to ensure that all the handlers are cleared from the bypassed list as expected.

#### Signature
```apex
private static testMethod void testClearAllBypasses()
```

#### Return Type
**void**

---

### `testRun_BeforeInsert()`

test the run method with the before insert trigger context using the 
MockTriggerHandler to ensure that the correct trigger context method is called.

#### Signature
```apex
private static testMethod void testRun_BeforeInsert()
```

#### Return Type
**void**

---

### `testRun_BeforeUpdate()`

test the run method with the before update trigger context using the 
MockTriggerHandler to ensure that the correct trigger context method is called.

#### Signature
```apex
private static testMethod void testRun_BeforeUpdate()
```

#### Return Type
**void**

---

### `testRun_BeforeDelete()`

test the run method with the before delete trigger context using the 
MockTriggerHandler to ensure that the correct trigger context method is called.

#### Signature
```apex
private static testMethod void testRun_BeforeDelete()
```

#### Return Type
**void**

---

### `testRun_AfterInsert()`

test the run method with the after insert trigger context using the 
MockTriggerHandler to ensure that the correct trigger context method is called.

#### Signature
```apex
private static testMethod void testRun_AfterInsert()
```

#### Return Type
**void**

---

### `testRun_AfterUpdate()`

test the run method with the after update trigger context using the 
MockTriggerHandler to ensure that the correct trigger context method is called.

#### Signature
```apex
private static testMethod void testRun_AfterUpdate()
```

#### Return Type
**void**

---

### `testRun_AfterDelete()`

test the run method with the after delete trigger context using the 
MockTriggerHandler to ensure that the correct trigger context method is called.

#### Signature
```apex
private static testMethod void testRun_AfterDelete()
```

#### Return Type
**void**

---

### `testRun_AfterUndelete()`

test the run method with the after undelete trigger context using the 
MockTriggerHandler to ensure that the correct trigger context method is called.

#### Signature
```apex
private static testMethod void testRun_AfterUndelete()
```

#### Return Type
**void**

---

### `testRun_NoContext()`

test the run method with no trigger context using the MockTriggerHandler to 
ensure that no trigger context method is called.

#### Signature
```apex
private static testMethod void testRun_NoContext()
```

#### Return Type
**void**

---

### `testValidateIsTriggerHandler()`

test the validateIsTriggerHandler method with the MockTriggerHandler to ensure 
that the handler is recognised as a valid TriggerHandler.

#### Signature
```apex
private static testMethod void testValidateIsTriggerHandler()
```

#### Return Type
**void**

---

### `testValidateIsTriggerHandler_EmptyHandlerName()`

test the validateIsTriggerHandler method with an empty handler name to ensure 
that a TriggerHandlerException is thrown as expected.

#### Signature
```apex
private static testMethod void testValidateIsTriggerHandler_EmptyHandlerName()
```

#### Return Type
**void**

---

### `testValidateIsTriggerHandler_NullHandlerName()`

test the validateIsTriggerHandler method with an null handler name to ensure 
that a TriggerHandlerException is thrown as expected.

#### Signature
```apex
private static testMethod void testValidateIsTriggerHandler_NullHandlerName()
```

#### Return Type
**void**

---

### `testValidateIsTriggerHandler_InvalidHandlerName()`

test the validateIsTriggerHandler method with an invalid handler name to ensure 
that a TriggerHandlerException is thrown as expected. Since only a class which 
extends TriggerHandler can be bypassed.

#### Signature
```apex
private static testMethod void testValidateIsTriggerHandler_InvalidHandlerName()
```

#### Return Type
**void**

---

### `testIsValid_MaxRecursionNullTriggerHandlerNotBypassed()`

test the isValid method using the MockTriggerHandler to ensure that it returns 
true when the maxRecursion is null and the TriggerHandler is not bypassed.

#### Signature
```apex
private static testMethod void testIsValid_MaxRecursionNullTriggerHandlerNotBypassed()
```

#### Return Type
**void**

---

### `testIsValid_MaxRecursionNotReachedTriggerHandlerNotBypassed()`

test the isValid method using the MockTriggerHandler to ensure that it returns 
true when the maxRecursion is greater than the recursionCount and the TriggerHandler 
is not bypassed.

#### Signature
```apex
private static testMethod void testIsValid_MaxRecursionNotReachedTriggerHandlerNotBypassed()
```

#### Return Type
**void**

---

### `testIsValid_MaxRecursionReached()`

test the isValid method using the MockTriggerHandler to ensure that it returns 
false when the recursionCount has reached maxRecursion.

#### Signature
```apex
private static testMethod void testIsValid_MaxRecursionReached()
```

#### Return Type
**void**

---

### `testIsValid_TriggerHandlerBypassed()`

test the isValid method using the MockTriggerHandler to ensure that it returns 
false when the TriggerHandler is bypassed.

#### Signature
```apex
private static testMethod void testIsValid_TriggerHandlerBypassed()
```

#### Return Type
**void**

---

### `testSetTriggerContext_NoContext()`

test the setTriggerContext method when no trigger has an active context.

#### Signature
```apex
private static testMethod void testSetTriggerContext_NoContext()
```

#### Return Type
**void**

---

### `testSetTriggerContext_NullContext()`

test the setTriggerContext method when null is passed as the trigger context.

#### Signature
```apex
private static testMethod void testSetTriggerContext_NullContext()
```

#### Return Type
**void**

---

### `testSetTriggerContext_WithContext()`

test the setTriggerContext method when trigger context is given.

#### Signature
```apex
private static testMethod void testSetTriggerContext_WithContext()
```

#### Return Type
**void**