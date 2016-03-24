/*

Related Test: batch_nightly_AcctHasActiveCC_Test

Business Purpose: Update "Has an Active CC" field on the Account

*/
global without sharing class batch_nightly_AcctHasActiveCC implements Database.Batchable<sObject> {
    
    global batch_nightly_AcctHasActiveCC() {}
    
    // Start                                    
    global Database.QueryLocator start(Database.BatchableContext BC){
    	system.debug('batch_nightly_AcctHasActiveCC - start');

        return Database.getQueryLocator('SELECT Id, (SELECT Id, Nbr_CCs_Active__c ' +
                                                    'FROM Loan_Programs__r ' +
                                                    'Order By Nbr_CCs_Active__c DESC) ' + 
                                        'FROM Account ' +
                                        'WHERE HasActiveCC_Updated__c < Today OR HasActiveCC_Updated__c = null');
    }

    // Execute
    global void execute(Database.BatchableContext BC, List<Account> scope){
        
        List<Account> updateAccounts = new List<Account>();

        for(Account acct : scope) {
            acct.Has_an_Active_CC__c = false;	
	    acct.HasActiveCC_Updated__c = system.now();
	    
            for(LP__c lp : acct.Loan_Programs__r) {
                if(lp.Nbr_CCs_Active__c > 0) {
                    acct.Has_an_Active_CC__c = true;
                    break;
                }
            }
            updateAccounts.add(acct);
        }

        if(!updateAccounts.isEmpty()) {
            database.update(updateAccounts,false);
        }
		
        system.debug('****************************** end batch_nightly_AcctHasActiveCC *********************************');
        system.debug('Limits::  ' + util_Methods.triggerLimitDebugs());
    }

    // Finish
    global void finish(Database.BatchableContext BC){
        system.debug('Finish Start');
        system.debug('Finish End');
    }
}
