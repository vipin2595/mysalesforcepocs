/*------------------------------------------------------------------------------
* Project Name..........: <<Workday>>
* File..................: <<ProposalLineItemTriggerHelper>>
* Version...............: <<1.0>>
* Created by............: <<Lirik.io>>
* Last Modified by......: <<Lirik.io>>
============================================================================================================
Purpose:                                                           
-------  
This class is an helper class for the Account object trigger.                                                          
============================================================================================================
History                                                           
-------                                                           
VERSION  AUTHOR            DATE              DETAIL                       Change Request
1.0 - Ravi             12/02/2015        SFDC-13077,  To calculate total sum of Line item ACV and save in parent object field Financial ACV          
2.0 - Ruslan Vekua     09/27/2018        GTMENT-1551, Call calculation engine computeData method on after proposal line item insert event
3.0 - Tarun Murikipudi 12/14/2018        GTMENT-2776, Auto create the ProposalLineItem for renewal.
4.0 - Ruslan 1/24/2019 changes - Fix CPU Timeout while finalizing a cart with growth
5.0 - Charles/Monisha   01/2019          GTMENT-2199 - Syncing the Worker Report Item fields to the new custom object (Proposal Worker Report Items) fields
6.0 - Denis             02/14/2019       GTMENT-3320 overwrite null date inorder renewal process not fail
7.0 - Vipin             02/22/2019       GTMENT- 3344 Populating Total workers count per SKU to proposal line item.
8.0 - Monisha           02/25/2019       GTMENT-3008 Report Adjustments for Quote Line Item & Quote Legacy vs New Gen Quotes  
9.0 - Ruslan            8/21/2019        GTMOM-1549 - Default check Max Language at time of Net New and Renewal
10.0 - VipinKommidi     10/24/2019       GTMOM-2066 - Update the quote as tier based configuration
11.0 - VipinKommidi     11/11/2019       GTMOM-2179 - When the Unlimited Tier is used the field "Tier Applied" is TRUE.
12.0 - Parvathi Chunduri 12/18/2019      GTMOM-2165 - When CAGR is greater than 35% rollup highest % & number of lines>35% to quote header
13.0 - Parvathi Chunduri 103/27/2020     GTMOM-2187 - Rolling Programatic Renewal Discounting fields from Proposal Line Item to Proposal header
14.0 - Prachi Dandriyal  6/02/2020       GTMSM-1674 - Set Scout Custom Bundle waiver flag when we select Custom Bundle from cart configuration
15.0 - Monisha Divakaran 07/02/2020      GTMOM-2780 - Quote Header page Fields
16.0 - Deepika Reddy Palwai 07/06/2020   GTMOM-2781 - Email Template fields to show on Quote Header
******************************************************************************************************************************************************************/
public class ProposalLineItemTriggerHelper {
    // this will copy data from formula value of ACV__c and save it to acv2
    // also will copy Product> include in financial ACV value in Include_in_financial_ACV_Product
    // IF(Apttus_Proposal__Proposal__r.RecordType.Name = "subscriptions",( Apttus_QPConfig__NetPrice__c / Apttus_QPConfig__SellingTerm__c )*12, 
    //  Apttus_QPConfig__NetPrice__c / Apttus_QPConfig__SellingTerm__c )
    //GTMOM 2781 Start 
    public static final String PRODUCT_SERVICE = 'Product/Service';
    public static final String OPTION = 'Option';
    public static final String PRICE_UOM_FSE = 'FSE';
    public static final String LINE_RENEWED = 'Renewed';
    //GTMOM 2781 End
    string strLTEProducts=Label.DALTE_Products;
    set<string> LTEProductsSet=new set<string>(strLTEProducts.split(';'));
    
    //GTMOM-2781 Start
    private static final RenewalSummaryCmpController renewalSummaryCntrl{
        get{
            if(renewalSummaryCntrl == null){
                renewalSummaryCntrl = new RenewalSummaryCmpController();
            }
            return renewalSummaryCntrl;
        }
        set;
    }
    //GTMOM-2781 End

    public void beforeInsert(List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItems) {

        Map<Id, Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemWithProduct = new map<Id, Apttus_Proposal__Proposal_Line_Item__c> ([
            SELECT 
                Id, Apttus_QPConfig__OptionId__c, 
                Apttus_QPConfig__OptionId__r.Name 
            FROM Apttus_Proposal__Proposal_Line_Item__c 
            WHERE Id IN :proposalLineItems
        ]);
        set<Id> lineItemIds = new set<id> ();
        set<Id> productIds = new Set<Id> ();
        List<Id> ProposalIds = new List<Id> ();
        String financialProductStr = Label.Financial_ACV_Products;
        set<string> ProposalIdSet=new set<string>();
        Set<String> financialAcvProductNames = new set<String> (financialProductStr.split(';'));
        String financialProductMasterStr = Label.Financial_ACV_Product_Master;
        Set<String> financialAcvProductMasterNames = new set<String> (financialProductMasterStr.split(';'));
        boolean isFinAcvList = false;
        set<Id> productIds1 = new Set<Id> ();

        for (Apttus_Proposal__Proposal_Line_Item__c proposalLineItem : proposalLineItems) {
            if (proposalLineItem.Apttus_QPConfig__DerivedFromId__c != null) {
                lineItemIds.add(proposalLineItem.Apttus_QPConfig__DerivedFromId__c);
            }
            if (proposalLineItem.Apttus_QPConfig__OptionId__c != null) {
                productIds.add(proposalLineItem.Apttus_QPConfig__OptionId__c);
            }
            
        }
        if (productIds.size() > 0) {
            for (Product2 pd2 :[SELECT 
                                    Id, Name 
                                FROM Product2 
                                WHERE Id IN :productIds]) {
                if (financialAcvProductMasterNames.contains(pd2.Name)) {
                    isFinAcvList = true;
                    break;
                }
            }
        }
        
        
        Map<Id, Apttus_Config2__LineItem__c> lineItemsMap = new Map<Id, Apttus_Config2__LineItem__c> ();
        if (lineItemIds.size() > 0) {
            lineItemsMap = new map<Id, Apttus_Config2__LineItem__c> ([
                SELECT 
                    Id, ACV__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ConfigurationId__r.Auto_Sync_Pending__c
                FROM Apttus_Config2__LineItem__c 
                WHERE Id IN :lineItemIds
            ]);
        }
        Map<Id, Product2> productMap = new Map<Id, Product2> ();
        if (productIds.size() > 0) {
            productMap = new Map<Id, Product2> ([
                SELECT 
                    Id, Name, Include_in_Financials_ACV__c, Family 
                FROM Product2 
                WHERE Id IN :productIds
            ]);
        }
        for (Apttus_Proposal__Proposal_Line_Item__c proposalLineItem : proposalLineItems) {
            Decimal acvValue;
            if (lineItemsMap.containsKey(proposalLineItem.Apttus_QPConfig__DerivedFromId__c) 
                && lineItemsMap.get(proposalLineItem.Apttus_QPConfig__DerivedFromId__c).Apttus_Config2__ConfigurationId__c != null 
                && lineItemsMap.get(proposalLineItem.Apttus_QPConfig__DerivedFromId__c).Apttus_Config2__ConfigurationId__r.Auto_Sync_Pending__c == true) {
                proposalLineItem.Auto_Sync_Pending__c = 1;
            }
            if (lineItemsMap.get(proposalLineItem.Apttus_QPConfig__DerivedFromId__c) != NULL) {
                proposalLineItem.Financials_ACV__c = lineItemsMap.get(proposalLineItem.Apttus_QPConfig__DerivedFromId__c).ACV__c;
            }
            if (productMap.get(proposalLineItem.Apttus_QPConfig__OptionId__c) != null) {
                proposalLineItem.Include_in_Financials_ACV__c = productMap.get(proposalLineItem.Apttus_QPConfig__OptionId__c).Include_in_Financials_ACV__c;
            }
            if (proposalLineItem.Apttus_QPConfig__OptionId__c != null) {
                String productName = productMap.get(proposalLineItem.Apttus_QPConfig__OptionId__c).Name;
                if (isFinAcvList && financialAcvProductNames.contains(productName)) {
                    proposalLineItem.Is_Financial__c = true;
                }
            if(LTEProductsSet.contains(productName))
                {
                    ProposalIdSet.add(proposalLineItem.Apttus_Proposal__Proposal__c);   
                }
            }
        }
        if(ProposalIdSet.size()>0)
        {
            list<Apttus_Proposal__Proposal__c> QuoteLst = new list<Apttus_Proposal__Proposal__c>();
            for(string strQId:ProposalIdSet) {
                Apttus_Proposal__Proposal__c q = new Apttus_Proposal__Proposal__c (id = strQId);
                q.Line_Item_has_LTE__c =true;
                QuoteLst.add(q);
            }
            update QuoteLst;   
            updateLegacyFieldsonPLI(proposalLineItems); //GTMENT-3008
        }
    }
    public void beforeUpdate(Map<Id, Apttus_Proposal__Proposal_Line_Item__c> oldMapProposalLineItems, Map<Id, Apttus_Proposal__Proposal_Line_Item__c> newMapProposalLineItems) {
        set<Id> lineItemIds = new set<id> ();
        set<Id> productIds = new Set<Id> ();
        for (Apttus_Proposal__Proposal_Line_Item__c proposalLineItem : newMapProposalLineItems.values()) {
            Apttus_Proposal__Proposal_Line_Item__c oldProposalLineItem = oldMapProposalLineItems.get(proposalLineItem.Id);
            if (proposalLineItem.Apttus_QPConfig__DerivedFromId__c != null && proposalLineItem.Apttus_QPConfig__DerivedFromId__c != oldProposalLineItem.Apttus_QPConfig__DerivedFromId__c) {
                lineItemIds.add(proposalLineItem.Apttus_QPConfig__DerivedFromId__c);
                //System.debug('proposalLineItem.Apttus_QPConfig__DerivedFromId__c>>>' + proposalLineItem.Apttus_QPConfig__DerivedFromId__c);
            }
            if (proposalLineItem.Apttus_QPConfig__OptionId__c != null && proposalLineItem.Apttus_QPConfig__OptionId__c != oldProposalLineItem.Apttus_QPConfig__OptionId__c) {
                productIds.add(proposalLineItem.Apttus_QPConfig__OptionId__c);
                //System.debug('proposalLineItem.Apttus_QPConfig__OptionId__c>>>' + proposalLineItem.Apttus_QPConfig__OptionId__c);
            }
        }
        Map<Id, Apttus_Config2__LineItem__c> lineItemsMap = new map<Id, Apttus_Config2__LineItem__c> ();
        if (lineItemIds.size() > 0) {

            lineItemsMap = new map<Id, Apttus_Config2__LineItem__c> ([
                SELECT 
                    Id, ACV__c
                FROM Apttus_Config2__LineItem__c 
                WHERE Id IN :lineItemIds
            ]);
        }
        Map<Id, Product2> productMap = new Map<Id, Product2> ();
        if (productIds.size() > 0) {
            productMap = new Map<Id, Product2> ([
                SELECT 
                    Id, Include_in_Financials_ACV__c 
                FROM Product2 
                WHERE Id IN :productIds
            ]);
        }
        for (Apttus_Proposal__Proposal_Line_Item__c proposalLineItem : newMapProposalLineItems.values()) {
            //Decimal acvValue;
            if (lineItemsMap.get(proposalLineItem.Apttus_QPConfig__DerivedFromId__c) != NULL) {
                proposalLineItem.Financials_ACV__c = lineItemsMap.get(proposalLineItem.Apttus_QPConfig__DerivedFromId__c).ACV__c;
                //System.debug('proposalLineItem.Financials_ACV__c>>>' + proposalLineItem.Financials_ACV__c);
            }
            if (productMap.get(proposalLineItem.Apttus_QPConfig__OptionId__c) != NULL) {
                proposalLineItem.Include_in_Financials_ACV__c = productMap.get(proposalLineItem.Apttus_QPConfig__OptionId__c).Include_in_Financials_ACV__c;
            }
        }
    }

    //Ruslan 1/24/2019 changes - Fix CPU Timeout while finalizing a cart with growth
    public void afterInsertProposalLines(Map<ID, Apttus_Proposal__Proposal_Line_Item__c> plisMap) {
        computePrices(plisMap);
        pliToQuoteUpd(plisMap);//GTMOM-1549//GTMOM-2066
        //Activate Quote trigger to fire it to calculate some data
        APTS_QuoteProposal_Tgr_Handler.APTS_QuoteProposal_Tgr_HandlerMap.put('BeforeUpdate', false);
        getProposalWorkerReportItem(plisMap.keyset()); //GTMENT-2199
    }
    
    //Denis GTMENT-3320 02/14/2019 overwrite null date inorder renewal process not fail
    public void beforeInsertProposalLines(List<Apttus_Proposal__Proposal_Line_Item__c> newRecsList) {
        for (Apttus_Proposal__Proposal_Line_Item__c pli : newRecsList) {
            if(pli.Apttus_QPConfig__StartDate__c == null
                && pli.Apttus_QPConfig__EndDate__c == null
                && pli.Apttus_QPConfig__SellingTerm__c == 0) {
                //pli.Apttus_QPConfig__StartDate__c = Date.newInstance(1970, 1, 1); //unix zero time
                //pli.Apttus_QPConfig__EndDate__c = Date.newInstance(1969, 12, 31); //unix zero time minus 1 day so term is zero
                //start GTMENT-3320 02/18/2019
                pli.Apttus_QPConfig__StartDate__c = pli.APTS_Initial_StartDate__c; //restore from saved date
                pli.Apttus_QPConfig__EndDate__c = pli.APTS_Initial_EndDate__c; ///restore from saved date
                //end GTMENT-3320 02/18/2019
            }
        }
        //GTMENT - 3344 Start
        totalworkerCount(newRecsList);
        //GTMENT - 3344 END
    }

    //Start GTMOM-1549
    /*******************************************************************
    Purpose:  Proposal line item to Quote update                                                        
    Parameters: Map of proposal line item id and proposal line item
    Returns: N/A
    Throws [Exceptions]: N/A                                                        
    ********************************************************************/ 
    @TestVisible
    private static void pliToQuoteUpd(Map<ID, Apttus_Proposal__Proposal_Line_Item__c> plisMap) {
        Set<string> ProposalTierAppIdSet = new Set<string>();// GTMOM-2066
        Set<string> ProposalIdSet = new Set<string>();// GTMOM-2066
        Set<string> ScoutProposalIdSet1 = new Set<string>();//GTMSM-1674
        Map<id,Integer> quoteidCAGRCountMap = new Map<id,Integer>(); //GTMOM-2165
        Map<id,Integer> quoteidCAGRMaxMap = new Map<id,Integer>(); //GTMOM-2165
        // Start GTMOM-2781
        Map<String, Apttus_Proposal__Proposal_Line_Item__c> groupProposalLineItemByProduct = new Map<String, Apttus_Proposal__Proposal_Line_Item__c>();
        Boolean hcmCheck = false; 
        Decimal maxBaselinePeppy = 0;
        Decimal lastGrowthLine = 0;
        // End GTMOM-2781 
      //  Map<id,Apttus_Proposal__Proposal__c> pliRollUpValuesToQuote = new Map<id,Apttus_Proposal__Proposal__c>();//GTMOM-2187
        Map<id,Apttus_Proposal__Proposal__c> QuoteLst = new Map<id,Apttus_Proposal__Proposal__c>();//2165 changed set to map for resuablity
        Integer maxlang = 0;
        final List<Apttus_Proposal__Proposal_Line_Item__c> plis = plisMap.values();
        
        if(!plis.isEmpty()){
            
            final ID cartId = plis[0].Apttus_QPConfig__ConfigurationId__c;
            Integer maxLangCount = 0;
            
            List<Apttus_Config2__LineItem__c> lineItems = [
                SELECT 
                    Apttus_Config2__AssetLineItemId__r.APTS_Max_Language__c 
                FROM Apttus_Config2__LineItem__c 
                WHERE Apttus_Config2__ConfigurationId__c = :cartId 
                AND Apttus_Config2__LineType__c = :PRODUCT_SERVICE 
                AND Opportunity_Type__c = 'Renewal' 
                AND Apttus_Config2__AssetLineItemId__c <> NULL
            ];
            
            if(!lineItems.isEmpty()){
                //Count if any max language value is set to TRUE
                for(Apttus_Config2__LineItem__c li : lineItems){
                    if(li.Apttus_Config2__AssetLineItemId__r.APTS_Max_Language__c){
                        maxlang += maxLangCount;
                    }
                }
                //Quote Max Language
                ProposalIdSet.add(plis[0].Apttus_Proposal__Proposal__c);// GTMOM-2066
                
            }
        }
        Apttus_Proposal__Proposal__c proposalToUpdate = new Apttus_Proposal__Proposal__c(); // GTMOM-2781
        // Start GTMOM-2066 //Updated to generalize the Query GTMOM-2187
        for(Apttus_Proposal__Proposal_Line_Item__c pli : [  
                SELECT 
                    Id,Apttus_Proposal__Proposal__c, Usage_Tier__c, Apttus_QPConfig__HasAttributes__c, APTS_CAGR_Formula__c, Apttus_QPConfig__LineStatus__c,
                    Apttus_Proposal__Proposal__r.APTS_SKUs_with_FSE_Ramp__c, Apttus_Proposal__Proposal__r.APTS_Max_FSE_CAGR__c, APTS_Volume_Discount__c,
                    APTS_Discretionary_DiscountACV__c, APTS_Renewal_Uplift__c, APTS_Price_Net_Uplift__c, APTS_Net_II_Rate__c, APTS_Delta_II_Rate__c, 
                    APTS_CPI_Net__c, APTS_II_Net_Amount__c, APTS_List_Price_CPI_ACV__c,APTS_CPI_Net_ACV__c, APTS_Volume_Discount_Amount__c,APTS_List_Price_II_ACV__c,
                    APTS_II_Net_ACV__c, Apttus_Proposal__Proposal__r.APTS_Volume_Discount__c, Apttus_Proposal__Proposal__r.APTS_Target_Innovation_Index__c, APTS_Expansion_Amount__c,
                    APTS_Volume_Discount_ACV__c, Apttus_Proposal__Proposal__r.APTS_Net_Innovation_Index__c, Apttus_Proposal__Proposal__r.APTS_Expansion_Baseline_ACV__c,
                    APTS_Discretionary_Discount__c, Apttus_Proposal__Proposal__r.APTS_Volume_Discount_ACV__c, Apttus_Proposal__Proposal__r.APTS_R_Net_Baseline_CPI__c,
                    Apttus_Proposal__Proposal__r.APTS_List_Price_CPI_ACV__c, Apttus_Proposal__Proposal__r.APTS_R_Net_Baseline_II__c, Apttus_Proposal__Proposal__r.APTS_Discretionary_Discount_ACV__c,
                    Apttus_Proposal__Proposal__r.APTS_List_Price_II_ACV__c, Apttus_Proposal__Proposal__r.APTS_Discretionary_Discount_TCV__c, Apttus_QPConfig__LineType__c,
                    Apttus_QPConfig__IsPrimaryLine__c, APTS_Configuration_Type__c,Apttus_Proposal__Proposal__r.APTS_Delta_Innovation_Index__c, APTS_Root_PN_II_Rate__c,
                    APTS_Pre_Negotiated_Term__c, APTS_II_Rate__c, Apttus_Proposal__Proposal__r.APTS_Quote_Identifier__c, Apttus_Proposal__Proposal__r.APTS_CustomBundle_Flag__c,
                    Apttus_Proposal__Product__r.ProductCode, Apttus_QPConfig__OptionId__r.ProductCode, Product_Code__c, Apttus_Proposal__Product__r.Name, AG_SKU_EY_Quantity__c,
                    Apttus_QPConfig__DerivedFromId__r.APTS_Growth_Adjusted_Baseline__c, Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__Quantity__c, Apttus_Proposal__Quantity__c, Apttus_QPConfig__IsPrimaryRampLine__c, 
                    Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__SellingTerm__c, Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__ExtendedPrice__c, Apttus_QPConfig__PriceUom__c,
                    Apttus_QPConfig__DerivedFromId__r.APTS_Baseline_PEPY__c, Apttus_QPConfig__DerivedFromId__r.Growth__c, Line_Item_Growth_Year__c  // Added for GTMSM-1674
                FROM Apttus_Proposal__Proposal_Line_Item__c 
                WHERE Id IN :plisMap.keyset() 
                AND APTS_Expansion_Type__c = null
        ])
        {
                //  Apttus_QPConfig__LineType__c = 'Option' and Apttus_QPConfig__IsPrimaryLine__c = true and 
                // GTMSM-1674 Start   
                if(pli.APTS_Configuration_Type__c == 'Bundle' && pli.Apttus_Proposal__Proposal__r.APTS_Quote_Identifier__c == true  && pli.Product_Code__c == Label.Scout_Custom_Bundle_Code) {
                    ScoutProposalIdSet1.add(pli.Apttus_Proposal__Proposal__c); 
                }
                // GTMSM-1674 End                                              
                //GTMOM-2179 Start
            if( pli.Apttus_QPConfig__LineType__c == OPTION && pli.Apttus_QPConfig__IsPrimaryLine__c == true && pli.Apttus_QPConfig__HasAttributes__c==true && pli.Usage_Tier__c !=null) {
                if(pli.Usage_Tier__c!='Unlimited') {
                    ProposalIdSet.add(pli.Apttus_Proposal__Proposal__c); 
                    ProposalTierAppIdSet.add(pli.Apttus_Proposal__Proposal__c);  
                }else {
                    ProposalIdSet.add(pli.Apttus_Proposal__Proposal__c); 
                }
            }
            //GTMOM-2179 End
           //GTMOM-2165 Start here
            String getLabelName = Label.APTS_CAGRThresholdPercentage;  
            if( pli.Apttus_QPConfig__LineType__c == OPTION && pli.Apttus_QPConfig__IsPrimaryLine__c == true && pli.APTS_CAGR_Formula__c !=null && pli.APTS_CAGR_Formula__c>Integer.valueOf(getLabelName)) {
                        if(quoteidCAGRCountMap.get(pli.Apttus_Proposal__Proposal__c)==null) {
                            quoteidCAGRCountMap.put(pli.Apttus_Proposal__Proposal__c, 1);
                        }else{
                            Integer count  = quoteidCAGRCountMap.get(pli.Apttus_Proposal__Proposal__c);
                            count++;
                            quoteidCAGRCountMap.put(pli.Apttus_Proposal__Proposal__c, count);
                        }
                }else if(!(quoteidCAGRCountMap.containsKey(pli.Apttus_Proposal__Proposal__c))) {
                    quoteidCAGRCountMap.put(pli.Apttus_Proposal__Proposal__c, 0);
                }
                if(pli.Apttus_QPConfig__LineType__c == OPTION && pli.Apttus_QPConfig__IsPrimaryLine__c && pli.APTS_CAGR_Formula__c !=null && pli.APTS_CAGR_Formula__c>0 ) {              
                    if(quoteidCAGRMaxMap.get(pli.Apttus_Proposal__Proposal__c)==null ) {
                        quoteidCAGRMaxMap.put(pli.Apttus_Proposal__Proposal__c,integer.valueOf(pli.APTS_CAGR_Formula__c));
                    }else {
                        if( quoteidCAGRMaxMap.get(pli.Apttus_Proposal__Proposal__c) <  pli.APTS_CAGR_Formula__c){
                            quoteidCAGRMaxMap.put(pli.Apttus_Proposal__Proposal__c,integer.valueOf(pli.APTS_CAGR_Formula__c ));
                        }        
                    }   
                }
                
            //GTMOM-2165 End here
            //GTMOM-2187 Start here
            
            if(pli.APTS_Configuration_Type__c == 'Bundle' && pli.Apttus_QPConfig__LineStatus__c == 'Renewed' && (pli.APTS_List_Price_CPI_ACV__c !=null || pli.APTS_List_Price_II_ACV__c !=null || pli.APTS_CPI_Net_ACV__c!=null ||pli.APTS_II_Net_ACV__c!=null || pli.APTS_Expansion_Amount__c!=null
                                            || pli.APTS_Discretionary_Discount__c!=null  || pli.APTS_Volume_Discount_ACV__c!=null ||pli.APTS_Volume_Discount__c!=null ||pli.APTS_Renewal_Uplift__c!=null || pli.APTS_Price_Net_Uplift__c!= null ||pli.APTS_Net_II_Rate__c!=null ||pli.APTS_Delta_II_Rate__c!=null)) {                
                
                proposalToUpdate.id = pli.Apttus_Proposal__Proposal__c; //GTMOM-2781
                proposalToUpdate.APTS_List_Price_CPI_ACV__c = pli.APTS_List_Price_CPI_ACV__c;
                proposalToUpdate.APTS_List_Price_II_ACV__c =  pli.APTS_List_Price_II_ACV__c;
                proposalToUpdate.APTS_R_Net_Baseline_CPI__c = pli.APTS_CPI_Net_ACV__c; 
                proposalToUpdate.APTS_R_Net_Baseline_II__c = pli.APTS_II_Net_ACV__c;
                proposalToUpdate.APTS_Expansion_Baseline_ACV__c   = pli.APTS_Expansion_Amount__c;
                proposalToUpdate.APTS_Discretionary_Discount_TCV__c = pli.APTS_Discretionary_Discount__c;
                proposalToUpdate.APTS_Discretionary_Discount_ACV__c = pli.APTS_Discretionary_DiscountACV__c;
                proposalToUpdate.APTS_Volume_Discount_ACV__c  = pli.APTS_Volume_Discount_Amount__c;
                proposalToUpdate.APTS_Volume_Discount__c  = pli.APTS_Volume_Discount__c;    
                proposalToUpdate.APTS_Target_Innovation_Index__c  = pli.APTS_Renewal_Uplift__c; //GTMOM-2780
                proposalToUpdate.APTS_Net_Uplift_Percent__c  = pli.APTS_Price_Net_Uplift__c; //GTMOM-2780                                                   
                proposalToUpdate.APTS_Net_Innovation_Index__c =   pli.APTS_Net_II_Rate__c;
                proposalToUpdate.APTS_Delta_Innovation_Index__c = pli.APTS_Delta_II_Rate__c;
                proposalToUpdate.APTS_Pre_Negotiated_Term__c = pli.APTS_Pre_Negotiated_Term__c;
                proposalToUpdate.APTS_Root_PN_II_Rate__c = pli.APTS_Root_PN_II_Rate__c;
                proposalToUpdate.APTS_II_Rate__c = pli.APTS_II_Rate__c; 
            //GTMOM-2187 ends here 
            }
        //GTMOM-2781 Start
        if(pli.Apttus_QPConfig__LineType__c == OPTION && pli.Apttus_QPConfig__LineStatus__c == LINE_RENEWED) {
            proposalToUpdate.id = pli.Apttus_Proposal__Proposal__c;
            
            if(pli.Apttus_QPConfig__DerivedFromId__r.Growth__c) {
                if(!hcmCheck) {
                    hcmCheck = renewalSummaryCntrl.isLineItemHasHcm(pli.Product_Code__c);
                }
                if(hcmCheck && renewalSummaryCntrl.isLineItemHasHcm(pli.Product_Code__c)) {
                    if(lastGrowthLine < pli.Line_Item_Growth_Year__c) {
                        lastGrowthLine = pli.Line_Item_Growth_Year__c;
                        proposalToUpdate =  processLineItems(
                                                proposalToUpdate, 
                                                pli, 
                                                pli.AG_SKU_EY_Quantity__c
                                            );
                    }
                }
                if(!hcmCheck && pli.Apttus_QPConfig__PriceUom__c == PRICE_UOM_FSE) {
                    if(!groupProposalLineItemByProduct.isEmpty() && groupProposalLineItemByProduct.containsKey(pli.Product_Code__c)) {
                        if(groupProposalLineItemByProduct.get(pli.Product_Code__c).Line_Item_Growth_Year__c < pli.Line_Item_Growth_Year__c) {
                            groupProposalLineItemByProduct.put(pli.Product_Code__c, pli);
                            proposalToUpdate =  processLineItems(
                                                    proposalToUpdate, 
                                                    pli, 
                                                    pli.AG_SKU_EY_Quantity__c
                                                );
                            maxBaselinePeppy = pli.Apttus_QPConfig__DerivedFromId__r.APTS_Baseline_PEPY__c;
                        }
                    }
                    else {
                        if(maxBaselinePeppy < pli.Apttus_QPConfig__DerivedFromId__r.APTS_Baseline_PEPY__c) {
                            proposalToUpdate =  processLineItems(
                                                    proposalToUpdate, 
                                                    pli, 
                                                    pli.AG_SKU_EY_Quantity__c
                                                );
                            groupProposalLineItemByProduct.put(pli.Product_Code__c, pli);
                            maxBaselinePeppy = pli.Apttus_QPConfig__DerivedFromId__r.APTS_Baseline_PEPY__c;
                        }
                    }
                }
            }
            else {
                if(!hcmCheck) {
                    hcmCheck = renewalSummaryCntrl.isLineItemHasHcm(pli.Product_Code__c);
                    if(hcmCheck) {
                        proposalToUpdate =  processLineItems(
                                                proposalToUpdate, 
                                                pli, 
                                                pli.Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__Quantity__c
                                            );
                    }
                }
                if(!hcmCheck && pli.Apttus_QPConfig__PriceUom__c == PRICE_UOM_FSE) {
                    if(maxBaselinePeppy < pli.Apttus_QPConfig__DerivedFromId__r.APTS_Baseline_PEPY__c) {
                        maxBaselinePeppy = pli.Apttus_QPConfig__DerivedFromId__r.APTS_Baseline_PEPY__c;
                        proposalToUpdate =  processLineItems(
                                                proposalToUpdate, 
                                                pli, 
                                                pli.Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__Quantity__c
                                            );
                    }
                }
            }
        }
        //GTMOM-2781 End
        if(proposalToUpdate.Id != null) {
            QuoteLst.put(pli.Apttus_Proposal__Proposal__c, proposalToUpdate);  
        }
    }  

        if(ProposalIdSet.size()>0)
        {
            for(string strQId : ProposalIdSet)
            {
                Apttus_Proposal__Proposal__c quote;// =new Apttus_Proposal__Proposal__c (id=strQId);
                if(QuoteLst.get(strQId) == null){ //GTMOM-2187
                    quote = new Apttus_Proposal__Proposal__c(id=strQId);
                }else{
                    quote =QuoteLst.get(strQId);
                }
                quote.APTS_Max_Language__c = maxlang > 0;
                // check if the proposal id contains  in strQId, then make Tier_Applied__c to true.
                if(ProposalTierAppIdSet.contains(strQId)){
                    quote.Tier_Applied__c=true; 
                }
                //GTMOM-2179 Start
                else{
                    quote.Tier_Applied__c=false; 
                }
                //GTMOM-2179 End
                QuoteLst.put(strQId,quote);
            }
        }
        
     //GTMOM-2165 Start here
        Set<id> quoteidset=new Set<id>();
        if(!quoteidCAGRCountMap.isEmpty()){
            quoteidset.addAll(quoteidCAGRCountMap.keySet());}
        if(!quoteidCAGRMaxMap.isEmpty()){
            quoteidset.addAll(quoteidCAGRMaxMap.keySet());
        }
        if(quoteidset.size()>0)
        {
            
            for(string strQId : quoteidset)
            {
                if(QuoteLst.get(strQId)==null){
                    Apttus_Proposal__Proposal__c quote =new Apttus_Proposal__Proposal__c (id=strQId);
                    if(quoteidCAGRCountMap.get(strQId)!=null){
                        quote.APTS_SKUs_with_FSE_Ramp__c=quoteidCAGRCountMap.get(strQId);
                    }
                    if(quoteidCAGRMaxMap.get(strQId)!=null){
                        quote.APTS_Max_FSE_CAGR__c=quoteidCAGRMaxMap.get(strQId);
                    }
            
                    QuoteLst.put(strQId,quote);
                }else{
                    Apttus_Proposal__Proposal__c quote =QuoteLst.get(strQId);
                    if(quoteidCAGRCountMap.get(strQId)!=null){
                        quote.APTS_SKUs_with_FSE_Ramp__c=quoteidCAGRCountMap.get(strQId);
                    }
                    if(quoteidCAGRMaxMap.get(strQId)!=null){
                        quote.APTS_Max_FSE_CAGR__c=quoteidCAGRMaxMap.get(strQId);
                    }
                    QuoteLst.put(strQId,quote);
                }
            }
        }
        //GTMSM-1674 Start
        if(ScoutProposalIdSet1.size()>0){
            for(string scstrQId :ScoutProposalIdSet1){
                Apttus_Proposal__Proposal__c quote = new Apttus_Proposal__Proposal__c(); 
                if(QuoteLst.get(scstrQId) == null){  
                    quote = new Apttus_Proposal__Proposal__c(id=scstrQId);
                }else{
                    quote =QuoteLst.get(scstrQId);
                }
                quote.APTS_CustomBundle_Flag__c  = true;
                QuoteLst.put(scstrQId,quote);
            
            }            
        }
        //GTMSM-1674 End
        //GTMOM-2165 end here
            if(QuoteLst!=null && !QuoteLst.isempty()){
                //QuoteProposalTriggerHelper.skipTrigger = true;
                update QuoteLst.values(); 
        }
    }
    //End GTMOM-2066
    
    //End GTMOM-1549
    /*******************************************************************
    Purpose: process propoosal line item                                                      
    Parameters: proposal, proposal line item, quantity
    Returns: Apttus_Proposal__Proposal__c
    Throws [Exceptions]: N/A                                                      
    ********************************************************************/ 
    private static Apttus_Proposal__Proposal__c processLineItems(Apttus_Proposal__Proposal__c proposalToUpdate, Apttus_Proposal__Proposal_Line_Item__c pli, Decimal Quantity) {
        proposalToUpdate.APTS_Growth_Adjusted_PEPY__c = calculateGrowthAdjustedPepy(
                                                                            pli.Apttus_QPConfig__DerivedFromId__r.APTS_Growth_Adjusted_Baseline__c,
                                                                            Quantity
                                                                        ); 
        proposalToUpdate.APTS_Target_Uplifted_PEPY__c = calculateTargetUpliftedPepy(
                                                            pli.Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__ExtendedPrice__c, 
                                                            pli.Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__SellingTerm__c,
                                                            Quantity
                                                        );
        return proposalToUpdate;
    }

    /*******************************************************************
    Purpose: Calculate growth adusted pepy                                                      
    Parameters: growthAdjustedBaseline, quantity
    Returns: Decimal
    Throws [Exceptions]: N/A                                                      
    ********************************************************************/ 
    private static Decimal calculateGrowthAdjustedPepy(Decimal growthAdjustedBaseline, Decimal Quantity) {
        Boolean growthPeppyCalcFieldsNull = renewalSummaryCntrl.nullCheck(
                                                    new Set<Decimal>{
                                                        growthAdjustedBaseline, 
                                                        Quantity
                                                    }
                                                );
        Decimal gowthAdjustedPepy = growthPeppyCalcFieldsNull 
                                    ? 0
                                    : growthAdjustedBaseline/Quantity;
        return gowthAdjustedPepy;
    }

    /*******************************************************************
    Purpose: Calculate target adusted pepy                                                      
    Parameters: extendedPrice,selling term, quantity
    Returns: Decimal
    Throws [Exceptions]: N/A                                                          
    ********************************************************************/ 
    private static Decimal calculateTargetUpliftedPepy(Decimal extendedPrice, Decimal Sellingterm, Decimal quantity) {
        Boolean targetPeppyCalcFieldsNull = renewalSummaryCntrl.nullCheck(
                                                    new Set<Decimal>{
                                                        extendedPrice, 
                                                        Sellingterm,
                                                        quantity
                                                    }
                                                );
        Decimal targetUpliftedPEPY = targetPeppyCalcFieldsNull
                                    ? 0
                                    : extendedPrice/Sellingterm/quantity;
        return targetUpliftedPEPY;

    }

    //Ruslan 1/24/2019 changes - Fix CPU Timeout while finalizing a cart with growth
    public static void computePrices(Map<ID, Apttus_Proposal__Proposal_Line_Item__c> plisMap) {
        
        System.debug('[IN] ProposalLineItemTriggerHelper.computePrices method');

        List<Apttus_Proposal__Proposal_Line_Item__c> plis = plisMap.values();

        if(!plis.isEmpty()){

            final ID proposalId = plis[0].Apttus_Proposal__Proposal__c;

            //Ruslan Vekua 9/19/2018' - GTMENT-1551 - Calculation Engine call
            final APTS_PricingEngineService pes = new APTS_PricingEngineService();
            pes.computeDataInMemory(new Apttus_Proposal__Proposal__c(id = proposalId), plis);
            //pes.computeData(proposalId, new List<ID> (plisIds));
            pes.commitChanges();
            
            /**
            *  Get all worker report items assocaited to the quote.
            *  Calculate number of special categories, categories renamed and weight percent change
            */
            List<APTS_WD_QWR__c> qwrs = [
                SELECT 
                    APTS_Worker_Report__c 
                FROM APTS_WD_QWR__c 
                WHERE APTS_Quote_Proposal__c = :proposalId
            ];
            if (!qwrs.isEmpty()) {
                
                final Set<ID> wrIds = new Set<ID> ();
                
                for (APTS_WD_QWR__c qwr : qwrs) { 
                    wrIds.add(qwr.APTS_Worker_Report__c);
                }
                
                if (!wrIds.isEmpty()) { 
                    Map<ID, APTS_WD_Worker_Report_Item__c> wrisMap = new Map<ID, APTS_WD_Worker_Report_Item__c> ([
                        SELECT 
                            Id 
                        FROM APTS_WD_Worker_Report_Item__c 
                        WHERE APTS_Worker_Report__c IN :wrIds
                    ]);
                    if (!wrisMap.isEmpty()) {
                        final APTS_PricingEngineService pes2 = new APTS_PricingEngineService();
                        pes2.computeData(proposalId, new List<ID> (wrisMap.keySet()));
                        pes2.commitChanges();
                    }
                }
            }
            //Start GTMENT-3374 - OM UAT: Net New - Sales ACV Needs to be Rounded to no decimals
            //final APTS_PricingEngineService pes3 = new APTS_PricingEngineService();
            //pes3.computeData(null, new List<ID>{proposalId});
            //pes3.commitChanges();
            //End GTMENT-3374
        }
        System.debug('[OUT] ProposalLineItemTriggerHelper.computePrices method');
    }

    /****
    Start  totalworkerCount
    GTMENT- 3344 Populating Total workers count per SKU to proposal line item.
    ****/
    
    public void totalworkerCount(List<Apttus_Proposal__Proposal_Line_Item__c> newRecsList) {
        Id firstLineitemWorkerReportId ;
        Set<id> WorkerReportIds = new Set<id>();
        Map<String,id> optionsMap = new Map<string,id>();
        for(Apttus_Proposal__Proposal_Line_Item__c pli : newRecsList) {
            //taking first line item of the worker report id
            if(pli.Apttus_QPConfig__LineType__c == PRODUCT_SERVICE ){
                firstLineitemWorkerReportId = pli.APTS_Worker_Report__c;
            }
            
            //Adding all worker report ids to the set
            if(pli.APTS_Worker_Report__c != null){
                WorkerReportIds.add(pli.APTS_Worker_Report__c); 
            }
            if(pli.Apttus_QPConfig__OptionId__c != null && pli.APTS_Worker_Report__c != null){
                optionsMap.put(pli.Apttus_QPConfig__OptionId__c,pli.APTS_Worker_Report__c);
            }
        }
        
        //Map contains worker report id as key and total worker as a value
        Map<id,Decimal> WorkerReportWithTotalWorkersMap = new Map<id,Decimal>();
        
        if(WorkerReportIds.size() > 0) {
            List<APTS_Worker_Report__c> workerreports = [
                SELECT 
                    Id, 
                    APTS_Total_Worker__c 
                FROM APTS_Worker_Report__c 
                WHERE Id IN : WorkerReportIds
            ];
            
            for(APTS_Worker_Report__c worker: workerreports) {

            //Adding worker report id as key and total worker as a value to map
            WorkerReportWithTotalWorkersMap.put(worker.id,worker.APTS_Total_Worker__c);

            }
        }
        for (Apttus_Proposal__Proposal_Line_Item__c newProposal : newRecsList) {
            
            //System.debug('firstLineitemWorkerReportId -->'+firstLineitemWorkerReportId);
            if(newProposal.Apttus_QPConfig__LineType__c != PRODUCT_SERVICE) {
                
                //System.debug('proposalLineItem if -->');
                
                // Check worker report is not null and autopopulate total worker field with total worker of worker report object.
                if(newProposal.APTS_Worker_Report__c != null && WorkerReportWithTotalWorkersMap.containsKey(newProposal.APTS_Worker_Report__c)){
                    newProposal.APTS_Total_Worker_SKU__c = WorkerReportWithTotalWorkersMap.get(newProposal.APTS_Worker_Report__c);
                    
                    //System.debug('proposalLineItem if if -->'+WorkerReportWithTotalWorkersMap.get(newProposal.APTS_Worker_Report__c));
                }
                // If worker report is null and option id not equal to null, autopopulate total worker based on the option.
                else if (newProposal.Apttus_QPConfig__OptionId__c != null && optionsMap.containsKey(newProposal.Apttus_QPConfig__OptionId__c )
                        ){
                    newProposal.APTS_Total_Worker_SKU__c = WorkerReportWithTotalWorkersMap.get(optionsMap.get(newProposal.Apttus_QPConfig__OptionId__c ));
                }
                 // If worker report is null and option id not equal to null, autopopulate total worker based on the option. 
                else{
                    //System.debug('proposalLineItem if else -->'+WorkerReportWithTotalWorkersMap.get(firstLineitemWorkerReportId));
                    newProposal.APTS_Total_Worker_SKU__c = WorkerReportWithTotalWorkersMap.get(firstLineitemWorkerReportId);
                }
            }
        }
    }
    /****  
    END totalworkerCount
    GTMENT- 3344 Populating Total workers count per SKU to proposal line item.
    ****/    
        
    /*
    *GTMENT-2776 - Proposal Line Item - Create Trigger: On creation copy the above fields from the quote,
    *to the corresponding fields on the root item where (Product Family = 'Subscription' and Line type = 'Product/Service'.  
    */
    public void autoCreationPLI(List<Apttus_Proposal__Proposal_Line_Item__c> newRecsList) {
        
        List<Id> ProposalIds = new List<Id> (); // decleration
        List<Id> ProductIds = new List<Id> ();  
        
        for (Apttus_Proposal__Proposal_Line_Item__c pli : newRecsList) {
            ProposalIds.add(pli.Apttus_Proposal__Proposal__c);
            ProductIds.add(pli.Apttus_Proposal__Product__c);
        }
        
        Map<Id, Product2> productMap = new Map<Id, Product2> ([
            SELECT 
                Id, Name, Family 
            FROM Product2 
            WHERE Id IN :ProductIds
        ]);
        Map<Id, Apttus_Proposal__Proposal__c> proposalMap = new Map<Id, Apttus_Proposal__Proposal__c> ([
            SELECT 
                Id, APTS_Apply_CPI_FR__c, APTS_Innovation_Index_for_FR__c, 
                APTS_Max_Uplift_for_FR__c,APTS_Future_Renewal_Term__c, 
                APTS_Future_Renewal_Frequence__c
            FROM Apttus_Proposal__Proposal__c 
            WHERE Id IN :ProposalIds
        ]);
        
        for (Apttus_Proposal__Proposal_Line_Item__c newProposal : newRecsList) {
            Apttus_Proposal__Proposal__c parentProposal = proposalMap.get(newProposal.Apttus_Proposal__Proposal__c);
            Product2 compareProduct = productMap.get(newProposal.Apttus_Proposal__Product__c);
            
            if (newProposal.Apttus_QPConfig__LineType__c == PRODUCT_SERVICE && compareProduct.Family == 'Subscription') { // condition
                newProposal.APTS_Apply_CPI_FR__c = parentProposal.APTS_Apply_CPI_FR__c;
                newProposal.APTS_Innovation_Index_for_FR__c = parentProposal.APTS_Innovation_Index_for_FR__c;
                newProposal.APTS_Max_Uplift_for_FR__c = parentProposal.APTS_Max_Uplift_for_FR__c;
                newProposal.APTS_Future_Renewal_Term__c = parentProposal.APTS_Future_Renewal_Term__c;
                newProposal.APTS_Future_Renewal_Frequency__c = parentProposal.APTS_Future_Renewal_Frequence__c;
            }
        }
    }
    
  // GTMENT-2199 starts
    public static void getProposalWorkerReportItem(Set<ID> plisIds) {
        
        List<Apttus_Proposal__Proposal_Line_Item__c> plis = [
            SELECT 
                Apttus_Proposal__Proposal__c 
            FROM Apttus_Proposal__Proposal_Line_Item__c 
            WHERE Id IN :plisIds LIMIT 1];
        final ID proposalId = plis[0].Apttus_Proposal__Proposal__c;
        
        List<APTS_Proposal_Worker_Report_Item__c> pwriToBeDeleted = [
            SELECT 
                Id
            FROM APTS_Proposal_Worker_Report_Item__c 
            WHERE APTS_Master_Quote__c =: proposalId];
        
        if(pwriToBeDeleted.size()>0) {
            delete pwriToBeDeleted;
        }
        
        //Get Quote Worker Report associated to the quote
        List<APTS_WD_QWR__c> qwrs = [
            SELECT 
                APTS_Worker_Report__c 
            FROM APTS_WD_QWR__c 
            WHERE APTS_Quote_Proposal__c = :proposalId
        ];
        if (!qwrs.isEmpty()) {
            
            //Worker report ids
            final Set<ID> wrIds = new Set<ID> ();
            
            for (APTS_WD_QWR__c qwr : qwrs) {
                wrIds.add(qwr.APTS_Worker_Report__c);
            }
            
            if (!wrIds.isEmpty()) {
                
                //Get exception worker reports
                Map<ID, APTS_Worker_Report__c> excWris = new Map<ID, APTS_Worker_Report__c>([
                    SELECT 
                        Id 
                    FROM APTS_Worker_Report__c 
                    WHERE APTS_Master_Worker_Report__c IN :wrIds
                ]);
                
                //Get all worker report items
                wrIds.addAll(excWris.keySet());
                List<APTS_WD_Worker_Report_Item__c> wris = [
                    SELECT 
                        Id,APTS_Override_Name__c,APTS_Override_Weight__c, 
                        APTS_Previous_Quantity__c, APTS_Product__c,
                        APTS_Worker_Report_Type__c,FSE_Final__c, 
                        FSE_Weight_Final__c, MasterQuote__c, 
                        Worker_Category_Final__c, 
                        APTS_Quantity__c,APTS_Total_Worker__c,
                        APTS_Report_Date__c ,APTS_Worker_Report_Total_FSE__c 
                    FROM APTS_WD_Worker_Report_Item__c 
                    WHERE APTS_Worker_Report__c IN :wrIds
                ];
                Map<String,APTS_CLMAccessFieldMapping__c> wrimap = new Map<String,APTS_CLMAccessFieldMapping__c>();
                List<APTS_CLMAccessFieldMapping__c > wriMappings = APTS_CLMAccessFieldMapping__c.getAll().values();
                
                for(APTS_CLMAccessFieldMapping__c wri :wriMappings){
                    
                    wrimap.put(wri.Source_Field_API_Name__c,wri);
                }
                
                if(!wris .isEmpty()) {
                    //The logic to pull data to the new custom object
                    List<APTS_Proposal_Worker_Report_Item__c> propWriLst = new List<APTS_Proposal_Worker_Report_Item__c>();
                    
                    for(APTS_WD_Worker_Report_Item__c wri : wris){
                        APTS_Proposal_Worker_Report_Item__c pwri = new APTS_Proposal_Worker_Report_Item__c();
                        
                        for(String s : wrimap.keyset()){
                            if(wrimap.get(s).Active__c){
                                //system.debug('s: '+s);
                                Decimal sourcevalueint;
                                String sourcevaluestr;
                                Date sourcevaluedate;
                                String targetField = wrimap.get(s).Target_Field_API_Name__c ;
                                //system.debug('targetField: '+targetField);
                                if(wrimap.get(s).Is_Number__c){
                                    sourcevalueint = (Decimal)wri.get(s);
                                }
                                else if(wrimap.get(s).Is_Date__c){
                                    
                                    sourcevaluedate = (Date)wri.get(s);
                                }
                                else{
                                    sourcevaluestr = (String)wri.get(s);
                                }
                                //system.debug('sourcevalueint: '+sourcevalueint);
                                //system.debug('sourcevaluestr: '+sourcevaluestr);
                                if(wrimap.get(s).Is_Number__c){                                     
                                    pwri.put(targetField, sourcevalueint);
                                }
                                else if(wrimap.get(s).Is_Date__c){
                                    pwri.put(targetField, sourcevaluedate);
                                }
                                else{
                                    pwri.put(targetField, sourcevaluestr); 
                                }
                                
                            }
                            pwri.APTS_Master_Quote__c = proposalId;
                            //system.debug('pwri: '+pwri);
                            
                        }
                        propWriLst.add(pwri);
                    }
                    
                    if(propWriLst.size()>0){
                        
                        insert propWriLst;
                    }
                }
            }
        }        
    }
    
  // GTMENT-2199 Ends

   // GTMENT-3008 starts

    public static void updateLegacyFieldsonPLI(List<Apttus_Proposal__Proposal_Line_Item__c> proposalList){
        ID proposalRtId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get(APTPS_Constants.RT_PROP_PROPOSAL).getRecordTypeID();
        List<Field_Mapping__c> fieldMapping = Field_Mapping__c.getAll().values();
        Map<String,Field_Mapping__c> legacyFieldMappingPLI = new Map<String,Field_Mapping__c>(); 
        for(Field_Mapping__c fm:fieldMapping){
            if(fm.Field_Mapping_Set__c == 'OM_PLI_LegacyForwardPopulate' && fm.Is_Active__c) {
                legacyFieldMappingPLI.put(fm.Source_Field__c, fm);      
            }
        }
        List<Apttus_Proposal__Proposal_Line_Item__c> pliLstToUpdate = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        for(Apttus_Proposal__Proposal_Line_Item__c pli:proposalList){
            if(pli.Apttus_Proposal__Proposal__r.RecordTypeID  != proposalRtId){
                for(String s : legacyFieldMappingPLI.keyset()){                       
                    //system.debug('s: '+s);
                    Decimal sourcevalueint;
                    String sourcevaluestr;
                    Date sourcevaluedate;
                    String targetField = legacyFieldMappingPLI.get(s).Target_Field__c  ;
                    if(legacyFieldMappingPLI.get(s).Data_Type__c == 'Decimal'){
                        sourcevalueint = (Decimal)pli.get(s);
                        pli.put(targetField, sourcevalueint);
                        
                    }
                    else if(legacyFieldMappingPLI.get(s).Data_Type__c == 'Date'){                           
                        sourcevaluedate = (Date)pli.get(s);
                        pli.put(targetField, sourcevaluedate);
                    }                        
                    
                    else{
                        sourcevaluestr = (String)pli.get(s);
                        pli.put(targetField, sourcevaluestr);  
                    }                        
                }
                pliLstToUpdate.add(pli);
            }
        }
    }
}