global with sharing class GetInventoryItems {



    @InvocableMethod(label='Get Inventory Items' description='Returns the list of productItems')
    global static List<String> getItems(List<ID> orderId){
        List<String> returnList = new List<String>();
        for(ID currentId:orderId){
            system.debug(orderId[0]);
            //First get the item id off of the sales order
            //plug in orderId[0] here to dynamically update
            List<PBSI__PBSI_Sales_Order_Line__c> salesorderlinelist = [SELECT Id, PBSI__Item__c,PBSI__Item__r.Name, PBSI__Quantity_Needed__c FROM PBSI__PBSI_Sales_Order_Line__c where PBSI__Sales_Order__c =: currentId];


            //return the product quantities and locations in separate query using the itemnumber and quantity needed as limiters
            List<List<PBSI__PBSI_Inventory__c>> ilist = new List<List<PBSI__PBSI_Inventory__c>>();
                        //iterate through salesorderlinelist
            for(PBSI__PBSI_Sales_Order_Line__c salesorderline:salesorderlinelist){
            	List<PBSI__PBSI_Inventory__c> myilist = [SELECT PBSI__qty__c, PBSI__location_lookup__c, PBSI__location_lookup__r.Name FROM PBSI__PBSI_Inventory__c WHERE PBSI__item_lookup__c =: salesorderline.PBSI__Item__c AND PBSI__qty__c > 0];
            	ilist.add(myilist);
            }

            //Dynamically returns the system base URL and adds the SF Maps tags/syntax
            String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
            system.debug(baseURL);

            baseURL = baseURL+'/apex/maps__maps?recordIds=';

            //append all of the records to the baseURL
            for(List<PBSI__PBSI_Inventory__c> l :ilist){
            for(PBSI__PBSI_Inventory__c p : l){
                system.debug(p.Id);
                baseURL = baseURL+String.valueof(p.Id)+',';
            }
            }
            system.debug(baseURL);
            baseURL = baseURL.substring(0, baseURL.length() -1);

            //Select hex value for color of markers
            String color = EncodingUtil.URLENCODE('#ff0000','UTF-8');
            system.debug(color);

            //Append all tooltips, base object, zoom, and color to the URL
            baseURL = baseURL+'&baseObjectId=a2E8Z0000077EolUAE&tooltipField=PBSI__location_lookup__r.Name&tooltipField2=PBSI__item_lookup__c&tooltipField3=PBSI__Description__c&tooltipField4=PBSI__qty__c&zoom=8&color='+color;
            system.debug(baseURL);
            returnList.add(baseURL);

            //render the points on the map by returning the custom url
            //return returnList;
        }
        return returnList;

    }
}
