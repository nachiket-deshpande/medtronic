trigger AssetProductTrigger on Asset (after insert, after update) {
    List<Asset> assets = new List<Asset>();
    List<Id> productIds = new List<Id>();
    List<Id> accountIds = new List<Id>();
    
    for( Asset asset : Trigger.new ) {
        if( asset.Product2Id != null &&
            asset.AccountId != null &&
            ( Trigger.isInsert || ( Trigger.isUpdate && ( Trigger.oldMap.get(asset.Id).Product2Id == null ) ) ) ) {
            assets.add( asset );
            productIds.add( asset.Product2Id );
            accountIds.add( asset.AccountId );
        }
    }
    
    AssetUtilities.updateAccountFlexProduct(assets, productIds, accountIds);
}