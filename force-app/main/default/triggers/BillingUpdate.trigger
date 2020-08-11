trigger BillingUpdate on Contact (after insert, after update) {
    Set<Id> conId = trigger.newMap.keySet();
    BillingCallout.makeCallout(conId);
}