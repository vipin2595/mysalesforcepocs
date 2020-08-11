@isTest (seeAllData=false)
private class OrderTests {
	@testSetup
    static void SetupTestData() {
        TestDataFactory.InsertTestData(20);
    }
   @isTest private static void orderUpdate_UnitTest() {
    	Order selectedOrder = [Select name,Status, Id from Order limit 1];
        Product2 oldProd = [Select Quantity_Ordered__c, Name, Id from Product2 limit 1];
        
        selectedOrder.Status = Constants.ACTIVATED_ORDER_STATUS;
        update selectedOrder;
        
        Product2 updatedProd = [Select Quantity_Ordered__c, Name, Id from Product2 limit 1];
        
        TestDataFactory.VerifyQuantityOrdered(oldProd,updatedProd,Constants.DEFAULT_ROWS);
    }
 @isTest private static void orderExtension_UnitTest() {
     PageReference pageRef = Page.OrderEdit;
    Test.setCurrentPage(pageRef);
    Order o = [SELECT Id, Status FROM Order LIMIT 1];
    ApexPages.StandardController stdcontroller = new ApexPages.StandardController(o);
    OrderExtension ext = new OrderExtension(stdcontroller);
    System.Equals(1, ext.orderItemList.size());
    ext.OnFieldChange();
    ext.SelectFamily();
    ext.Save();
    ext.First();
    ext.Next();
    ext.Previous();
    ext.Last();
    ext.GetHasPrevious();
    ext.GetHasNext();
    ext.GetTotalPages();
    ext.GetPageNumber();
    List<SelectOption> options = ext.GetFamilyOptions();
 }
}