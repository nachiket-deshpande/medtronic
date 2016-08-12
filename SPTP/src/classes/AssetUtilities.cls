public with sharing class AssetUtilities {
	public static void updateAccountFlexProduct(List<Asset> assets,
		List<Id> productIds,
		List<Id> accountIds) {
			
		if( assets.size() == 0 ) {
			return;
		}
		
		Map<Id,Product2> productsMap = new Map<Id,Product2>( [SELECT Id, Name from Product2 where Id IN :productIds] );
		Map<Id,Account> accountsMap = new Map<Id,Account>( [SELECT Id, HALOFlex_Account__c, Flex_Account_Since__c from Account where Id IN :accountIds] );
		
        Set<Account> accounts = new Set<Account>();
	//	List<Account> accounts = new List<Account>();
		
		for( Asset asset : assets ) {
			Account account = accountsMap.get( asset.AccountId );
			Product2 product = productsMap.get( asset.Product2Id );
			
			if( account == null ||
				product == null ||
				!product.Name.toLowerCase().contains('flex') ) {
				continue;
			}
			
			account.HALOFlex_Account__c = true;
			
			if( account.Flex_Account_Since__c == null ) {
				account.Flex_Account_Since__c = asset.InstallDate;
			}
			
			accounts.add(account);
		}
		List <Account> accountsList = new List <Account>(accounts);
		//update accounts;
		update accountsList;
	}
    
@future
Public Static Void UpdateRepOnGeneratorAssets ()
{  
List <Asset> generators = new List <Asset>();

for(Asset generator : [select Id, name, account.Id, account.Inside_Sales_Rep__c, 
                        account.Inside_Sales_Rep__r.FirstName, account.Inside_Sales_Rep__r.LastName, 
                        account.Inside_Sales_rep__r.manager.id, user__c, user__r.Firstname, user__r.Lastname,
                        Product_Code__c from Asset where ((Product_Code__c ='1190A-115A' or 
                     Product_Code__c ='1190A-115A-01' or Product_Code__c ='1190A-115A-R') and (account.Inside_Sales_rep__c !=null))])
{
    if ((generator.account.Inside_Sales_Rep__c != generator.user__c) && (generator.user__c != generator.account.Inside_Sales_rep__r.manager.id)){
        if (generator.account.Inside_Sales_Rep__r.FirstName=='Open')
            generator.user__c= generator.account.Inside_Sales_rep__r.manager.id;
        else 
            generator.user__c= generator.account.Inside_Sales_rep__c;
            
   //   system.debug('>>>>>>> Asset with diff rep - Asset ID: '+generator.id+' User: '+ generator.user__r.Firstname+' '+generator.user__r.lastname+ ' Inter Rep: '+ generator.account.interventional_rep__r.firstname+ ' '+generator.account.interventional_rep__r.lastname);    
        generators.add(generator);
    }
}
  //  system.debug('Number of generators for update: '+generators.size()) ;   

update generators;  
}
    
}