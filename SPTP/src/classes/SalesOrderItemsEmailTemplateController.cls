public class SalesOrderItemsEmailTemplateController {
  public Id salesOrderId {get;set;}
  public List <OrderLine__c> getOrderLines() {
    OrderLine__c [] lst = new List<OrderLine__c>();
    lst = [SELECT Quantity_Ordered__c, ItemDescription1__c, Sales_Rep__r.Name
             FROM OrderLine__c 
            WHERE ExtendedPrice__c > 0 and Order__c = :salesOrderId];
    return lst;
  }   
}