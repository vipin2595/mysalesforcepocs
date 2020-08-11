/**
* This class contains unit tests for validating the behavior of Apex class ProposalLineItemTriggerHelper and Aptps_ProposalLineItemTrigger.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class ProposalLineItemTriggerHelperTest {

    @TestSetup
    static void constructInitialData(){
        APTS_TestSetup.createAndInsertCustomSettings();
        APTS_TestSetup.createInitialData();
        APTS_TestSetup.createWorkerModelInitialData();
    }
    // create product,Create line item , create proposal,create proposal line item
    static testMethod void myUnitTest() {
        
        Data_Management__c restrictWF_PB = Data_Management__c.getInstance();
        restrictWF_PB.Restrict_Opportunity_Workflow_PB__c = false;
        insert restrictWF_PB;
        
        List<Field_Mapping__c> fieldsMapping = new List<Field_Mapping__c>();
        
        fieldsMapping.add(new Field_Mapping__c(
            
            Name = 'OM_ProposalLineItem_SKU_TCV',
            Field_Mapping_Set__c = 'OM_PLI_LegacyForwardPopulate',
            Is_Active__c = true,
            Source_Field__c = 'Line_Item_TCV__c',
            Target_Field__c = 'AG_SKU_TCV__c',
            Data_Type__c = 'Decimal'
            
        ));
        
        fieldsMapping.add(new Field_Mapping__c(
            
            Name = 'OM_ProposalLineItem_AACV',
            Field_Mapping_Set__c = 'OM_PLI_LegacyForwardPopulate',
            Is_Active__c = true,
            Source_Field__c = 'Line_Item_ACV__c',
            Target_Field__c = 'AACV__c',
            Data_Type__c = 'Decimal'
            
        ));
        
        fieldsMapping.add(new Field_Mapping__c(
            
            Name = 'OM_ProposalLineItem_Final_Base_PEPY',
            Field_Mapping_Set__c = 'OM_PLI_LegacyForwardPopulate',
            Is_Active__c = true,
            Source_Field__c = 'Sync_PEPY__c',
            Target_Field__c = 'APTS_Final_Base_PEPY__c',
            Data_Type__c = 'Decimal'
            
        ));
        
        fieldsMapping.add(new Field_Mapping__c(
            
            Name = 'OM_ProposalLineItem_StartDate',
            Field_Mapping_Set__c = 'OM_PLI_LegacyForwardPopulate',
            Is_Active__c = true,
            Source_Field__c = 'Line_item_start_date__c',
            Target_Field__c = 'Apttus_QPConfig__StartDate__c',
            Data_Type__c = 'Date'
            
        ));
        
        fieldsMapping.add(new Field_Mapping__c(
            
            Name = 'OM_ProposalLineItem_EndDate',
            Field_Mapping_Set__c = 'OM_PLI_LegacyForwardPopulate',
            Is_Active__c = true,
            Source_Field__c = 'Line_Item_End_Date__c',
            Target_Field__c = 'Apttus_QPConfig__EndDate__c',
            Data_Type__c = 'Date'
            
        ));
        
        fieldsMapping.add(new Field_Mapping__c(
            
            Name = 'OM_Quote_SKU_Pricing_Model',
            Field_Mapping_Set__c = 'OM_Quote_LegacyForwardPopulate',
            Is_Active__c = true,
            Source_Field__c = 'BundleSelection__c',
            Target_Field__c = 'APTS_SKU_Pricing_Model__c',
            Data_Type__c = 'String'
            
        ));
        
        insert fieldsMapping;    
        
        
        Account acc = APTS_TestDataFactoryUtil.getAccount('Prospect', 'Prospect');
        acc.BillingCountry='Austria';
        insert acc;
        
        APTS_Number_Of_Employees__c numberOfEmployees = APTS_TestSetup.createNumberOfEmployees('3600', 3600);
        insert numberOfEmployees;
        
        Data_Migration__c dm = new Data_Migration__c();
        dm.Name = 'Opportunity';
        dm.Name__c = 'Opportunity';
        dm.Exclude_Triggers__c = false;
        
        insert dm;
        
        Data_Migration__c dm1 = new Data_Migration__c();
        dm1.Name = 'ProposalLineItem';
        dm1.Name__c = 'ProposalLineItem';
        dm1.Exclude_Triggers__c = false;
        
        insert dm1;        
        
        APTS_String_Constants__c apsc= new APTS_String_Constants__c();
        apsc.name ='RT_PROP_PROPOSAL';
        apsc.Value__c ='Proposal';  
        insert apsc;
        
        OpportunityTriggerHelper.skipTrigger = true;
        Opportunity opty = APTS_TestSetup.createOpportunity('WD oppty',acc.Id);
        
        insert opty;
        
        Apttus_Config2__PriceList__c plist = APTS_TestDataFactoryUtil.getPriceList();
        insert pList;
        
        Apttus_Proposal__Proposal__c proposal = APTS_TestDataFactoryUtil.getQuoteProposal(acc, opty, pList.Id, 'Proposal');
        proposal.BundleSelection__c = 'LE';
        proposal.Subscription_Start_Date__c = System.today();
        proposal.Subscription_End_Date__c = System.today() + 1200;
        proposal.Quote_Term__c = 40;
        proposal.CPI__c = 10;
        proposal.Incentive_Credit__c = 0.01;
        proposal.APTS_SKUs_with_FSE_Ramp__c = 3;
        proposal.APTS_Max_FSE_CAGR__c = 38;
        proposal.Tier_Applied__c = True;
        proposal.APTS_Max_Language__c = True;
        proposal.RecordTypeId = APTS_TestDataFactoryUtil.getTrainingRecordTypeId();
        APTS_ApprovalService.skipCalculation = true;
        APTS_QuoteProposal_Tgr_Handler.skipTrigger = true;
        proposal.APTS_Quote_Identifier__c=false;
        insert proposal;
        
        proposal = [SELECT Id, Name, APTS_OpportunityType__c, Growth__c, Quote_Term__c, Opportunity_Record_Type__c, BundleSelection__c, CPI__c,
                    Apttus_QPConfig__PriceListId__c, RecordType.Name, Incentive_Credit__c, Subscription_Start_Date__c, Subscription_End_Date__c,
                    Apttus_Proposal__Discount_Percent__c, Quote_Term_in_Days__c, CurrencyIsoCode,APTS_Quote_Identifier__c FROM Apttus_Proposal__Proposal__c WHERE Id = :proposal.Id];
        
        Apttus_Config2__ProductConfiguration__c pConfig = APTS_TestDataFactoryUtil.getProductConfiguration('Product Configuration', 1, proposal.Id, 'Proposal', 'Product', 
                                                                                                           pList.Id, null, 'New', null, null, false, 'test apttus config');
        
        insert pConfig;
        
        Product2 prodLE = APTS_TestDataFactoryUtil.getProduct('Large Enterprise', 'LE', 'Bundle', 'Subscription');
        prodLE.Apttus_Config2__HasAttributes__c = true;
        
        Product2 prodUSP = APTS_TestDataFactoryUtil.getProduct('Core Financials', 'USP', 'Option', 'Subscription');
        prodUSP.Apttus_Config2__HasAttributes__c = true;
        prodUSP.bound_to_HCM__c = 'Payroll';
        prodUSP.Subscriptions_Product_Category__c = 'USP';
        prodUSP.Exlude_from_translations__c = true;
        prodUSP.Sync_If_Type__c = 'Option';
        prodUSP.relevant_WT__c = 'Salaried Workers; Hourly Workers; Part-Time Workers; Seasonal Workers; Associates; Other; Miscellaneous; Full-Time Workers';
        prodUSP.Tool_Value__c = 2000;
        prodUSP.Applicable_Tools_Factors__c = APTPS_Constants.APPLICABLE_TOOLS_FACTOR_EMPLOYEE;
        
        // creating product
        Product2 prod1 = APTS_TestDataFactoryUtil.getProduct('Delivery Assurance Project Management Reviews LTE LDP', 'DALDP', 'Option', 'Subscription');
        prod1.Sync_If_Type__c = 'Primary';  
        
        Product2 prodCustom = APTS_TestDataFactoryUtil.getProduct('Workday Strategic Sourcing Custom', 'SW-CUST-FY20', 'Bundle', 'Subscription');
        //Product
        insert new List<Product2>{prodLE, prodUSP,prod1,prodCustom};
            
            Apttus_Config2__PriceListItem__c plItemLE = APTS_TestDataFactoryUtil.getPriceListItem(plist.Id, prodLE.Id, APTPS_Constants.CHARGE_TYPE_SP, 'One Time', 'Per Unit', 9485, 9000, 10000, 'Unit Price');
        Apttus_Config2__PriceListItem__c plItemUSP = APTS_TestDataFactoryUtil.getPriceListItem(plist.Id, prodUSP.Id, APTPS_Constants.CHARGE_TYPE_SP, 'One Time', 'Per Unit', 9485, 9000, 10000, 'Unit Price');
        Apttus_Config2__PriceListItem__c plItemCustom = APTS_TestDataFactoryUtil.getPriceListItem(plist.Id, prodCustom.Id, APTPS_Constants.CHARGE_TYPE_SP, 'One Time', 'Per Unit', 9485, 9000, 10000, 'Unit Price');
        
        insert new List<Apttus_Config2__PriceListItem__c>{plItemLE, plItemUSP,plItemCustom};
            
            Apttus_Config2__AssetLineItem__c ali =APTS_TestSetup.createBundleAssetLineItem(plist.id, prodLE.id, plItemLE.id);
        Insert ali;
        
        List<Apttus_Config2__LineItem__c> listLineItemSO_LE = new List<Apttus_Config2__LineItem__c>();
        Apttus_Config2__LineItem__c lineItemSO_LE = APTS_TestDataFactoryUtil.getLineItem(pConfig.Id, null, 1, true, 1, 'Product/Service', prodLE.Id, 
                                                                                         true, null, null, null, null, 1, true, 'Each', 1, plist.Id, plItemLE.Id, 'One Time', 'Per Unit', null, null, true, true, 9485, 9485, 
                                                                                         'Per Unit', 9485, null, 9485, 'LE Bundle');
        lineItemSO_LE.ACV__c = 100;
        lineItemSO_LE.Apttus_Config2__AssetLineItemId__c = ali.Id;
        listLineItemSO_LE.add(lineItemSO_LE);
        
        Apttus_Config2__LineItem__c lineItemSO_LE1 = APTS_TestDataFactoryUtil.getLineItem(pConfig.Id, null, 1, true, 1, 'Option', prodUSP.Id, 
                                                                                          true, null, null, null, null, 1, true, 'Each', 1, plist.Id, plItemUSP.Id, 'One Time', 'Per Unit', null, null, true, true, 9485, 9485, 
                                                                                          'Per Unit', 9485, null, 9485, 'Option Desc');
        lineItemSO_LE1.ACV__c = 100;
        lineItemSO_LE1.APTS_Expansion_Type__c = null;
        listLineItemSO_LE.add(lineItemSO_LE1);
        
        
        Apttus_Config2__LineItem__c lineItemScout = APTS_TestDataFactoryUtil.getLineItem(pConfig.Id, null, 1, true, 1, 'Product/Service', prodCustom.Id, 
                                                                                         true, null, null, null, null, 1, true, 'Each', 1, plist.Id, plItemCustom.Id, 'One Time', 'Per Unit', null, null, true, true, 9485, 9485, 
                                                                                         'Per Unit', 9485, null, 9485, 'Option Desc');
        listLineItemSO_LE.add(lineItemScout);
        insert listLineItemSO_LE;
        
        Apttus_Proposal__Proposal__c quoteProposalObj = new Apttus_Proposal__Proposal__c();
        quoteProposalObj.Apttus_Proposal__Proposal_Name__c = 'test proposal';
        quoteProposalObj.Apttus_Proposal__Opportunity__c = opty.id;
        quoteProposalObj.RecordTypeId = APTS_TestDataFactoryUtil.getTrainingRecordTypeId();
        insert quoteProposalObj;
        
        List<Apttus_Proposal__Proposal_Line_Item__c> listProposalLineItem = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = new Apttus_Proposal__Proposal_Line_Item__c();
        proposalLineItem.Apttus_QPConfig__DerivedFromId__c = listLineItemSO_LE[0].Id;
        proposalLineItem.Apttus_QPConfig__OptionId__c=prod1.id;
        proposalLineItem.Apttus_Proposal__Product__c = prodLE.Id;
        proposalLineItem.Include_in_Financials_ACV__c = true;
        proposalLineItem.Apttus_QPConfig__LineType__c = 'Product/Service';
        proposalLineItem.Apttus_Proposal__Proposal__c = quoteProposalObj.Id;
        //proposalLineItem.Apttus_QPConfig__OptionId__c=prodUSP.id;
        proposalLineItem.Apttus_QPConfig__ConfigurationId__c = pConfig.Id;
        proposalLineItem.APTS_Expansion_Type__c='';
        proposalLineItem.Apttus_QPConfig__HasAttributes__c = True;
        proposalLineItem.Usage_Tier__c = 'Low';
        proposalLineItem.APTS_CAGR_Formula__c = 40;
        listProposalLineItem.add(proposalLineItem);
        //insert proposalLineItem;
        
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem1 = new Apttus_Proposal__Proposal_Line_Item__c();
        proposalLineItem1.Apttus_QPConfig__DerivedFromId__c = listLineItemSO_LE[1].Id;
        proposalLineItem1.Apttus_QPConfig__OptionId__c=prodUSP.id;
        proposalLineItem1.Apttus_Proposal__Product__c = prodLE.Id;
        proposalLineItem1.Include_in_Financials_ACV__c = true;
        proposalLineItem1.Apttus_QPConfig__LineType__c = 'Option';
        proposalLineItem1.Apttus_Proposal__Proposal__c = quoteProposalObj.Id;
        proposalLineItem1.Apttus_QPConfig__ConfigurationId__c = pConfig.Id;
        proposalLineItem1.APTS_Expansion_Type__c=null;
        proposalLineItem1.Apttus_QPConfig__HasAttributes__c = True;
        proposalLineItem1.Usage_Tier__c = 'Low';
        proposalLineItem1.APTS_CAGR_Formula__c = 40;
        proposalLineItem1.Apttus_QPConfig__IsPrimaryLine__c = true;
        listProposalLineItem.add(proposalLineItem1);
        
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem4 = new Apttus_Proposal__Proposal_Line_Item__c();
        proposalLineItem4.Apttus_QPConfig__DerivedFromId__c = listLineItemSO_LE[2].Id;
        proposalLineItem4.Apttus_QPConfig__OptionId__c=prodCustom.id;
        proposalLineItem4.Apttus_Proposal__Product__c = prodCustom.Id;
        proposalLineItem4.Include_in_Financials_ACV__c = true;
        proposalLineItem4.Apttus_QPConfig__LineType__c = 'Product/Service';
        proposalLineItem4.Apttus_Proposal__Proposal__c = quoteProposalObj.Id;
        proposalLineItem4.Apttus_QPConfig__ConfigurationId__c = pConfig.Id;
        listProposalLineItem.add(proposalLineItem4);
        
        insert listProposalLineItem;
        
        
        listProposalLineItem[0].Apttus_Proposal__Product__c = prodUSP.Id;
        listProposalLineItem[0].Apttus_QPConfig__OptionId__c=prodLE.Id;
        
        //listProposalLineItem[1].Apttus_QPConfig__IsPrimaryLine__c = true;
        
        update listProposalLineItem;
        
        
        //insert proposalLineItem;
        
        APTS_CLMAccessFieldMapping__c cs = new APTS_CLMAccessFieldMapping__c(Name = 'FSE (Final)',Object_Name__c = 'WorkerReportItem',Source_Field_API_Name__c = 'FSE_Final__c',
                                                                             Target_Field_API_Name__c = 'APTS_FSE_Final__c',Active__c = true,
                                                                             Is_Number__c = true);
        APTS_CLMAccessFieldMapping__c cs1 = new APTS_CLMAccessFieldMapping__c(Name = 'Override Category',Object_Name__c = 'WorkerReportItem',Source_Field_API_Name__c = 'APTS_Override_Name__c',
                                                                              Target_Field_API_Name__c = 'APTS_Override_Category__c',Active__c = true);
        APTS_CLMAccessFieldMapping__c cs2 = new APTS_CLMAccessFieldMapping__c(Name = 'Report Date',Object_Name__c = 'WorkerReportItem',Source_Field_API_Name__c = 'APTS_Report_Date__c',
                                                                              Target_Field_API_Name__c = 'APTS_Report_Date__c',Active__c = true, Is_Date__c = true
                                                                             );
        APTS_CLMAccessFieldMapping__c cs3 = new APTS_CLMAccessFieldMapping__c(Name = 'Worker Category (Final)',Object_Name__c = 'WorkerReportItem',Source_Field_API_Name__c = 'Worker_Category_Final__c',
                                                                              Target_Field_API_Name__c = 'APTS_Worker_Category_Final__c',Active__c = true
                                                                             );
        APTS_CLMAccessFieldMapping__c cs4 = new APTS_CLMAccessFieldMapping__c(Name = 'FSE Weight (Final)',Object_Name__c = 'WorkerReportItem',Source_Field_API_Name__c = 'FSE_Weight_Final__c',
                                                                              Target_Field_API_Name__c = 'APTS_FSE_Weight_Final__c',Active__c = true,
                                                                              Is_Number__c = true);
        APTS_CLMAccessFieldMapping__c cs5 = new APTS_CLMAccessFieldMapping__c(Name = 'Quantity / Workers',Object_Name__c = 'WorkerReportItem',Source_Field_API_Name__c = 'APTS_Quantity__c',
                                                                              Target_Field_API_Name__c = 'APTS_Quantity_Workers__c',Active__c = true, 
                                                                              Is_Number__c = true);
        APTS_CLMAccessFieldMapping__c cs6 = new APTS_CLMAccessFieldMapping__c(Name = 'Previous Category Count',Object_Name__c = 'WorkerReportItem',Source_Field_API_Name__c = 'APTS_Previous_Quantity__c',
                                                                              Target_Field_API_Name__c = 'APTS_Previous_Category_Count__c',Active__c = true,
                                                                              Is_Number__c = true);
        
        
        insert new List<APTS_CLMAccessFieldMapping__c>{cs,cs1,cs2,cs3,cs4,cs5,cs6};
            
            Test.startTest();
        
        APTS_Worker_Report__c workerReport = [select id from APTS_Worker_Report__c Limit 1];
        APTS_WD_QWR__c quoteWorkerReport = APTS_TestSetup.createQuoteWorkerReport(proposal.id, workerReport.id);
        insert quoteWorkerReport;
        
        Apttus_Proposal__Proposal__c prp = APTS_TestSetup.createProposal(opty.id, plist.id);
        insert prp;
        
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem2 = listProposalLineItem[0].clone();
        proposalLineItem2.Apttus_Proposal__Proposal__c = prp.Id;
        insert proposalLineItem2;
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem3 = listProposalLineItem[1].clone();
        proposalLineItem3.Apttus_Proposal__Proposal__c = proposal.Id;
        proposalLineItem3.APTS_Worker_Report__c = workerReport.id;
        insert proposalLineItem3;
        Set<id> setOfIds = new Set<id>();
        setOfIds.add(proposalLineItem3.id);
        ProposalLineItemTriggerHelper.getProposalWorkerReportItem(setOfIds);
        ProposalLineItemTriggerHelper ll =new ProposalLineItemTriggerHelper();
        List<Apttus_Proposal__Proposal_Line_Item__c> newRecsList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        listProposalLineItem[0].Apttus_Proposal__Product__c = prodUSP.Id;
        update listProposalLineItem[0];
        newRecsList.add(proposalLineItem3);
        newRecsList.addAll(listProposalLineItem);
        
        Map<Id, Apttus_Proposal__Proposal_Line_Item__c> newRecMap = new Map<Id, Apttus_Proposal__Proposal_Line_Item__c>();
        for(Apttus_Proposal__Proposal_Line_Item__c pli : newRecsList){
            newRecMap.put(pli.id,pli);
        }
        ll.autoCreationPLI(newRecsList);
        ll.beforeInsertProposalLines(newRecsList);
        ll.afterInsertProposalLines(newRecMap);
        
        Test.stopTest();
    }

    @isTest
    static void hcmNonGrowthTargetAndGrowthPeppyCalc(){
        Opportunity oppty = [
            SELECT 
                Id 
            FROM Opportunity 
            LIMIT 1
        ]; 

        Account acc = [
            SELECT 
                Id 
            FROM Account 
            LIMIT 1
        ];

        Apttus_Config2__PriceList__c priceList = [
            SELECT 
                Id 
            FROM Apttus_Config2__PriceList__c 
            LIMIT 1
        ];
        Apttus_Config2__PriceListItem__c pli = [
            SELECT 
                Id 
            FROM Apttus_Config2__PriceListItem__c 
            LIMIT 1
        ];

        Product2 subscriptionProduct = APTS_TestSetup.createProduct('Product 1', 'Subscription');
            subscriptionProduct.Apttus_Config2__ConfigurationType__c = ProposalLineItemTriggerHelper.PRODUCT_SERVICE;

        Product2 optionProduct = APTS_TestSetup.createProduct('Product 1', 'HCM');
            optionProduct.bound_to_HCM__c = 'Full';
            optionProduct.Apttus_Config2__ConfigurationType__c = ProposalLineItemTriggerHelper.OPTION;

        Product2 optionProduct1 = APTS_TestSetup.createProduct('Product 2', 'TT');
            optionProduct1.bound_to_HCM__c = 'Partial';
            optionProduct1.Apttus_Config2__ConfigurationType__c = ProposalLineItemTriggerHelper.OPTION;

        insert new List<Product2>{
            subscriptionProduct,
            optionProduct,
            optionProduct1 
        }; 

        Test.startTest();
            Apttus_Proposal__Proposal__c proposal = APTS_TestSetup.createProposal(oppty.Id,priceList.Id);
            insert proposal;

            Apttus_Config2__ProductConfiguration__c productConfig = APTS_TestSetup.createCart(proposal.Id,priceList.Id); 
            insert productConfig;

            Apttus_Config2__LineItem__c  bunbleLineItem = APTS_TestSetup.createLineItem(
                                                            priceList.Id, 
                                                            productConfig.Id, 
                                                            subscriptionProduct.Id, 
                                                            pli.Id
                                                        );
            Apttus_Config2__LineItem__c  optionLineItem1 = APTS_TestSetup.createLineItem(
                                                                priceList.Id, 
                                                                productConfig.Id, 
                                                                optionProduct.Id, 
                                                                pli.Id
                                                            );
            optionLineItem1.Apttus_Config2__LineType__c = ProposalLineItemTriggerHelper.OPTION;
            optionLineItem1.Apttus_Config2__Quantity__c = 2;
            optionLineItem1.APTS_Growth_Adjusted_Baseline__c = 100;
            optionLineItem1.Apttus_Config2__ExtendedPrice__c = 1000;
            optionLineItem1.Apttus_Config2__SellingTerm__c = 2 ;
            optionLineItem1.AG_Ramp_Line_Count__c = 0;

            Apttus_Config2__LineItem__c  optionLineItem2 = APTS_TestSetup.createLineItem(
                                                                priceList.Id,
                                                                productConfig.Id,
                                                                optionProduct1.Id,
                                                                pli.Id
                                                            );
            optionLineItem2.Apttus_Config2__LineType__c = ProposalLineItemTriggerHelper.OPTION;
            optionLineItem2.Apttus_Config2__Quantity__c = 4;
            optionLineItem2.APTS_Growth_Adjusted_Baseline__c = 1000;
            optionLineItem2.Apttus_Config2__ExtendedPrice__c = 10000;
            optionLineItem2.Apttus_Config2__SellingTerm__c = 2 ;
            optionLineItem2.AG_Ramp_Line_Count__c = 0;
            
            insert new List<Apttus_Config2__LineItem__c>{
                bunbleLineItem,
                optionLineItem1,
                optionLineItem2
            };

            Apttus_Config2__ProductAttributeValue__c prductAttribute = new Apttus_Config2__ProductAttributeValue__c();
            prductAttribute.Apttus_Config2__LineItemId__c = optionLineItem1.Id;
            prductAttribute.Growth__c = false;

            insert prductAttribute;

            optionLineItem1.Apttus_Config2__AttributeValueId__c = prductAttribute.Id;
            update optionLineItem1;
            
            Apttus_Proposal__Proposal_Line_Item__c bundleProposalLineItem = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                subscriptionProduct.Id
                                                                            );
            bundleProposalLineItem.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            bundleProposalLineItem.Apttus_QPConfig__DerivedFromId__c = bunbleLineItem.Id;
            
            Apttus_Proposal__Proposal_Line_Item__c optionProposalLineItem = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                optionProduct.Id
                                                                            );
            optionProposalLineItem.Apttus_QPConfig__LineType__c = proposalLineItemTriggerHelper.OPTION;
            optionProposalLineItem.Apttus_QPConfig__PriceUom__c = ProposalLineItemTriggerHelper.PRICE_UOM_FSE;
            optionProposalLineItem.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            optionProposalLineItem.Apttus_QPConfig__DerivedFromId__c = optionLineItem1.Id;

            Apttus_Proposal__Proposal_Line_Item__c optionProposalLineItem2 = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                optionProduct1.Id
                                                                            );
            optionProposalLineItem2.Apttus_QPConfig__LineType__c = proposalLineItemTriggerHelper.OPTION;
            optionProposalLineItem2.Apttus_QPConfig__PriceUom__c = ProposalLineItemTriggerHelper.PRICE_UOM_FSE;
            optionProposalLineItem2.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            optionProposalLineItem2.Apttus_QPConfig__DerivedFromId__c = optionLineItem2.Id;

            insert new List<Apttus_Proposal__Proposal_Line_Item__c>{
                bundleProposalLineItem,
                optionProposalLineItem, 
                optionProposalLineItem2
            };
            
            ProposalLineItemTriggerHelper.pliToQuoteUpd(
                new map<Id, Apttus_Proposal__Proposal_Line_Item__c> { 
                    bundleProposalLineItem.Id => bundleProposalLineItem,
                    optionProposalLineItem.Id => optionProposalLineItem,
                    optionProposalLineItem2.Id => optionProposalLineItem2
                }
            );
        Test.stopTest();
    }
    
    @isTest
    static void hcmWithGrowthTargetAndGrowthPeppyCalc(){

        Opportunity oppty = [
            SELECT 
                Id 
            FROM Opportunity 
            LIMIT 1
        ]; 

        Account acc = [
            SELECT 
                Id 
            FROM Account 
            LIMIT 1
        ];

        Apttus_Config2__PriceList__c priceList = [
            SELECT 
                Id 
            FROM Apttus_Config2__PriceList__c 
            LIMIT 1
        ];
        Apttus_Config2__PriceListItem__c pli = [
            SELECT 
                Id 
            FROM Apttus_Config2__PriceListItem__c 
            LIMIT 1
        ];

        Product2 subscriptionProduct = APTS_TestSetup.createProduct('Product 1', 'Subscription');
            subscriptionProduct.Apttus_Config2__ConfigurationType__c = ProposalLineItemTriggerHelper.PRODUCT_SERVICE;

        Product2 optionProduct = APTS_TestSetup.createProduct('Product 1', 'HCM');
            optionProduct.bound_to_HCM__c = 'Full';
            optionProduct.Apttus_Config2__ConfigurationType__c = ProposalLineItemTriggerHelper.OPTION;

        Product2 optionProduct1 = APTS_TestSetup.createProduct('Product 2', 'TT');
            optionProduct1.bound_to_HCM__c = 'Partial';
            optionProduct1.Apttus_Config2__ConfigurationType__c = ProposalLineItemTriggerHelper.OPTION;

        insert new List<Product2>{
            subscriptionProduct,
            optionProduct,
            optionProduct1 
        }; 

        Test.startTest();
            Apttus_Proposal__Proposal__c proposal = APTS_TestSetup.createProposal(oppty.Id,priceList.Id);
            insert proposal;

            Apttus_Config2__ProductConfiguration__c productConfig = APTS_TestSetup.createCart(proposal.Id,priceList.Id); 
            insert productConfig;

            Apttus_Config2__LineItem__c  bunbleLineItem = APTS_TestSetup.createLineItem(
                                                            priceList.Id, 
                                                            productConfig.Id, 
                                                            subscriptionProduct.Id, 
                                                            pli.Id
                                                        );
            Apttus_Config2__LineItem__c  optionLineItem = APTS_TestSetup.createLineItem(
                                                                priceList.Id, 
                                                                productConfig.Id, 
                                                                optionProduct.Id, 
                                                                pli.Id
                                                            );
            optionLineItem.Apttus_Config2__LineType__c = ProposalLineItemTriggerHelper.OPTION;
            optionLineItem.Apttus_Config2__Quantity__c = 2;
            optionLineItem.APTS_Growth_Adjusted_Baseline__c = 100;
            optionLineItem.Apttus_Config2__ExtendedPrice__c = 1000;
            optionLineItem.Apttus_Config2__SellingTerm__c = 2 ;
            optionLineItem.AG_Ramp_Line_Count__c = 2;

            Apttus_Config2__LineItem__c  optionLineItem1 = APTS_TestSetup.createLineItem(
                                                                priceList.Id, 
                                                                productConfig.Id, 
                                                                optionProduct.Id, 
                                                                pli.Id
                                                            );
            optionLineItem1.Apttus_Config2__LineType__c = ProposalLineItemTriggerHelper.OPTION;
            optionLineItem1.Apttus_Config2__Quantity__c = 2;
            optionLineItem1.APTS_Growth_Adjusted_Baseline__c = 100;
            optionLineItem1.Apttus_Config2__ExtendedPrice__c = 1000;
            optionLineItem1.Apttus_Config2__SellingTerm__c = 2 ;
            optionLineItem1.AG_Ramp_Line_Count__c = 2;

            Apttus_Config2__LineItem__c  optionLineItem2 = APTS_TestSetup.createLineItem(
                                                                priceList.Id,
                                                                productConfig.Id,
                                                                optionProduct1.Id,
                                                                pli.Id
                                                            );
            optionLineItem2.Apttus_Config2__LineType__c = ProposalLineItemTriggerHelper.OPTION;
            optionLineItem2.Apttus_Config2__Quantity__c = 4;
            optionLineItem2.APTS_Growth_Adjusted_Baseline__c = 1000;
            optionLineItem2.Apttus_Config2__ExtendedPrice__c = 10000;
            optionLineItem2.Apttus_Config2__SellingTerm__c = 2 ;
            optionLineItem2.AG_Ramp_Line_Count__c = 2;

            Apttus_Config2__LineItem__c  optionLineItem3 = APTS_TestSetup.createLineItem(
                                                                priceList.Id,
                                                                productConfig.Id,
                                                                optionProduct1.Id,
                                                                pli.Id
                                                            );
            optionLineItem3.Apttus_Config2__LineType__c = ProposalLineItemTriggerHelper.OPTION;
            optionLineItem3.Apttus_Config2__Quantity__c = 4;
            optionLineItem3.APTS_Growth_Adjusted_Baseline__c = 1000;
            optionLineItem3.Apttus_Config2__ExtendedPrice__c = 10000;
            optionLineItem3.Apttus_Config2__SellingTerm__c = 2 ;
            optionLineItem3.AG_Ramp_Line_Count__c = 2;
            
            insert new List<Apttus_Config2__LineItem__c>{
                bunbleLineItem,
                optionLineItem,
                optionLineItem1,
                optionLineItem2,
                optionLineItem3
            };
            
            Apttus_Proposal__Proposal_Line_Item__c bundleProposalLineItem = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                subscriptionProduct.Id
                                                                            );
            bundleProposalLineItem.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            bundleProposalLineItem.Apttus_QPConfig__DerivedFromId__c = bunbleLineItem.Id;
            
            Apttus_Proposal__Proposal_Line_Item__c optionProposalLineItem = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                optionProduct.Id
                                                                            );
            optionProposalLineItem.Apttus_QPConfig__LineType__c = proposalLineItemTriggerHelper.OPTION;
            optionProposalLineItem.Apttus_QPConfig__PriceUom__c = ProposalLineItemTriggerHelper.PRICE_UOM_FSE;
            optionProposalLineItem.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            optionProposalLineItem.Apttus_QPConfig__DerivedFromId__c = optionLineItem.Id;
            optionProposalLineItem.Apttus_QPConfig__IsPrimaryRampLine__c = true;
            optionProposalLineItem.APTS_Year__c = 1;

            Apttus_Proposal__Proposal_Line_Item__c optionProposalLineItem1 = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                optionProduct.Id
                                                                            );
            optionProposalLineItem1.Apttus_QPConfig__LineType__c = proposalLineItemTriggerHelper.OPTION;
            optionProposalLineItem1.Apttus_QPConfig__PriceUom__c = ProposalLineItemTriggerHelper.PRICE_UOM_FSE;
            optionProposalLineItem1.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            optionProposalLineItem1.Apttus_QPConfig__DerivedFromId__c = optionLineItem1.Id;
            optionProposalLineItem1.APTS_Year__c = 2;

            Apttus_Proposal__Proposal_Line_Item__c optionProposalLineItem2 = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                optionProduct1.Id
                                                                            );
            optionProposalLineItem2.Apttus_QPConfig__LineType__c = proposalLineItemTriggerHelper.OPTION;
            optionProposalLineItem2.Apttus_QPConfig__PriceUom__c = ProposalLineItemTriggerHelper.PRICE_UOM_FSE;
            optionProposalLineItem2.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            optionProposalLineItem2.Apttus_QPConfig__IsPrimaryRampLine__c = true;
            optionProposalLineItem2.Apttus_QPConfig__DerivedFromId__c = optionLineItem2.Id;
            optionProposalLineItem2.APTS_Year__c = 1;

            Apttus_Proposal__Proposal_Line_Item__c optionProposalLineItem3 = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                optionProduct1.Id
                                                                            );
            optionProposalLineItem3.Apttus_QPConfig__LineType__c = proposalLineItemTriggerHelper.OPTION;
            optionProposalLineItem3.Apttus_QPConfig__PriceUom__c = ProposalLineItemTriggerHelper.PRICE_UOM_FSE;
            optionProposalLineItem3.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            optionProposalLineItem3.Apttus_QPConfig__DerivedFromId__c = optionLineItem3.Id;
            optionProposalLineItem3.APTS_Year__c = 2;

            insert new List<Apttus_Proposal__Proposal_Line_Item__c>{
                bundleProposalLineItem,
                optionProposalLineItem, 
                optionProposalLineItem1, 
                optionProposalLineItem2,
                optionProposalLineItem3
            };
            
            ProposalLineItemTriggerHelper.pliToQuoteUpd(
                new map<Id, Apttus_Proposal__Proposal_Line_Item__c> { 
                    bundleProposalLineItem.Id => bundleProposalLineItem,
                    optionProposalLineItem.Id => optionProposalLineItem,
                    optionProposalLineItem1.Id => optionProposalLineItem1,
                    optionProposalLineItem2.Id => optionProposalLineItem2,
                    optionProposalLineItem3.Id => optionProposalLineItem3
                }
            );
        Test.stopTest();
    }

    @isTest
    static void nonHcmWithoutGrowthTargetAndGrowthPeppyCalc(){
        Opportunity oppty = [
            SELECT 
                Id 
            FROM Opportunity 
            LIMIT 1
        ]; 

        Account acc = [
            SELECT 
                Id 
            FROM Account 
            LIMIT 1
        ];

        Apttus_Config2__PriceList__c priceList = [
            SELECT 
                Id 
            FROM Apttus_Config2__PriceList__c 
            LIMIT 1
        ];
        Apttus_Config2__PriceListItem__c pli = [
            SELECT 
                Id 
            FROM Apttus_Config2__PriceListItem__c 
            LIMIT 1
        ];

        Product2 subscriptionProduct = APTS_TestSetup.createProduct('Product 1', 'Subscription');
            subscriptionProduct.Apttus_Config2__ConfigurationType__c = ProposalLineItemTriggerHelper.PRODUCT_SERVICE;

        Product2 optionProduct = APTS_TestSetup.createProduct('Product 1', 'PP');
            optionProduct.bound_to_HCM__c = 'Full';
            optionProduct.Apttus_Config2__ConfigurationType__c = ProposalLineItemTriggerHelper.OPTION;

        Product2 optionProduct1 = APTS_TestSetup.createProduct('Product 2', 'TT');
            optionProduct1.bound_to_HCM__c = 'Partial';
            optionProduct1.Apttus_Config2__ConfigurationType__c = ProposalLineItemTriggerHelper.OPTION;

        insert new List<Product2>{
            subscriptionProduct,
            optionProduct,
            optionProduct1 
        }; 

        Test.startTest();
            Apttus_Proposal__Proposal__c proposal = APTS_TestSetup.createProposal(oppty.Id,priceList.Id);
            insert proposal;

            Apttus_Config2__ProductConfiguration__c productConfig = APTS_TestSetup.createCart(proposal.Id,priceList.Id); 
            insert productConfig;

            Apttus_Config2__LineItem__c  bunbleLineItem = APTS_TestSetup.createLineItem(
                                                            priceList.Id, 
                                                            productConfig.Id, 
                                                            subscriptionProduct.Id, 
                                                            pli.Id
                                                        );
            Apttus_Config2__LineItem__c  optionLineItem1 = APTS_TestSetup.createLineItem(
                                                                priceList.Id, 
                                                                productConfig.Id, 
                                                                optionProduct.Id, 
                                                                pli.Id
                                                            );
            optionLineItem1.Apttus_Config2__LineType__c = ProposalLineItemTriggerHelper.OPTION;
            optionLineItem1.Apttus_Config2__Quantity__c = 2;
            optionLineItem1.APTS_Growth_Adjusted_Baseline__c = 100;
            optionLineItem1.Apttus_Config2__ExtendedPrice__c = 1000;
            optionLineItem1.Apttus_Config2__SellingTerm__c = 2 ;
            optionLineItem1.AG_Ramp_Line_Count__c = 0;
            optionLineItem1.APTS_Baseline_PEPY__c = 10;

            Apttus_Config2__LineItem__c  optionLineItem2 = APTS_TestSetup.createLineItem(
                                                                priceList.Id,
                                                                productConfig.Id,
                                                                optionProduct1.Id,
                                                                pli.Id
                                                            );
            optionLineItem2.Apttus_Config2__LineType__c = ProposalLineItemTriggerHelper.OPTION;
            optionLineItem2.Apttus_Config2__Quantity__c = 4;
            optionLineItem2.APTS_Growth_Adjusted_Baseline__c = 1000;
            optionLineItem2.Apttus_Config2__ExtendedPrice__c = 10000;
            optionLineItem2.Apttus_Config2__SellingTerm__c = 2 ;
            optionLineItem2.AG_Ramp_Line_Count__c = 0;
            optionLineItem2.APTS_Baseline_PEPY__c = 20;
            
            insert new List<Apttus_Config2__LineItem__c>{
                bunbleLineItem,
                optionLineItem1,
                optionLineItem2
            };

            Apttus_Config2__ProductAttributeValue__c prductAttribute = new Apttus_Config2__ProductAttributeValue__c();
            prductAttribute.Apttus_Config2__LineItemId__c = optionLineItem1.Id;
            prductAttribute.Growth__c = false;

            insert prductAttribute;

            optionLineItem1.Apttus_Config2__AttributeValueId__c = prductAttribute.Id;
            update optionLineItem1;
            
            Apttus_Proposal__Proposal_Line_Item__c bundleProposalLineItem = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                subscriptionProduct.Id
                                                                            );
            bundleProposalLineItem.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            bundleProposalLineItem.Apttus_QPConfig__DerivedFromId__c = bunbleLineItem.Id;
            
            Apttus_Proposal__Proposal_Line_Item__c optionProposalLineItem = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                optionProduct.Id
                                                                            );
            optionProposalLineItem.Apttus_QPConfig__LineType__c = proposalLineItemTriggerHelper.OPTION;
            optionProposalLineItem.Apttus_QPConfig__PriceUom__c = ProposalLineItemTriggerHelper.PRICE_UOM_FSE;
            optionProposalLineItem.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            optionProposalLineItem.Apttus_QPConfig__DerivedFromId__c = optionLineItem1.Id;

            Apttus_Proposal__Proposal_Line_Item__c optionProposalLineItem2 = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                optionProduct1.Id
                                                                            );
            optionProposalLineItem2.Apttus_QPConfig__LineType__c = proposalLineItemTriggerHelper.OPTION;
            optionProposalLineItem2.Apttus_QPConfig__PriceUom__c = ProposalLineItemTriggerHelper.PRICE_UOM_FSE;
            optionProposalLineItem2.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            optionProposalLineItem2.Apttus_QPConfig__DerivedFromId__c = optionLineItem2.Id;

            insert new List<Apttus_Proposal__Proposal_Line_Item__c>{
                bundleProposalLineItem,
                optionProposalLineItem, 
                optionProposalLineItem2
            };
            
            ProposalLineItemTriggerHelper.pliToQuoteUpd(
                new map<Id, Apttus_Proposal__Proposal_Line_Item__c> { 
                    bundleProposalLineItem.Id => bundleProposalLineItem,
                    optionProposalLineItem.Id => optionProposalLineItem,
                    optionProposalLineItem2.Id => optionProposalLineItem2
                }
            );
        Test.stopTest();
    }

    @isTest
    static void nonHcmWithGrowthTargetAndGrowthPeppyCalc(){
        Opportunity oppty = [
            SELECT 
                Id 
            FROM Opportunity 
            LIMIT 1
        ]; 

        Account acc = [
            SELECT 
                Id 
            FROM Account 
            LIMIT 1
        ];

        Apttus_Config2__PriceList__c priceList = [
            SELECT 
                Id 
            FROM Apttus_Config2__PriceList__c 
            LIMIT 1
        ];
        Apttus_Config2__PriceListItem__c pli = [
            SELECT 
                Id 
            FROM Apttus_Config2__PriceListItem__c 
            LIMIT 1
        ];

        Product2 subscriptionProduct = APTS_TestSetup.createProduct('Product 1', 'Subscription');
            subscriptionProduct.Apttus_Config2__ConfigurationType__c = ProposalLineItemTriggerHelper.PRODUCT_SERVICE;

        Product2 optionProduct = APTS_TestSetup.createProduct('Product 1', 'PP');
            optionProduct.bound_to_HCM__c = 'Full';
            optionProduct.Apttus_Config2__ConfigurationType__c = ProposalLineItemTriggerHelper.OPTION;

        Product2 optionProduct1 = APTS_TestSetup.createProduct('Product 2', 'TT');
            optionProduct1.bound_to_HCM__c = 'Partial';
            optionProduct1.Apttus_Config2__ConfigurationType__c = ProposalLineItemTriggerHelper.OPTION;

        insert new List<Product2>{
            subscriptionProduct,
            optionProduct,
            optionProduct1 
        }; 

        Test.startTest();
            Apttus_Proposal__Proposal__c proposal = APTS_TestSetup.createProposal(oppty.Id,priceList.Id);
            insert proposal;

            Apttus_Config2__ProductConfiguration__c productConfig = APTS_TestSetup.createCart(proposal.Id,priceList.Id); 
            insert productConfig;

            Apttus_Config2__LineItem__c  bunbleLineItem = APTS_TestSetup.createLineItem(
                                                            priceList.Id, 
                                                            productConfig.Id, 
                                                            subscriptionProduct.Id, 
                                                            pli.Id
                                                        );
            Apttus_Config2__LineItem__c  optionLineItem = APTS_TestSetup.createLineItem(
                                                                priceList.Id, 
                                                                productConfig.Id, 
                                                                optionProduct.Id, 
                                                                pli.Id
                                                            );
            optionLineItem.Apttus_Config2__LineType__c = ProposalLineItemTriggerHelper.OPTION;
            optionLineItem.Apttus_Config2__Quantity__c = 2;
            optionLineItem.APTS_Growth_Adjusted_Baseline__c = 100;
            optionLineItem.Apttus_Config2__ExtendedPrice__c = 1000;
            optionLineItem.Apttus_Config2__SellingTerm__c = 2 ;
            optionLineItem.AG_Ramp_Line_Count__c = 2;
            optionLineItem.APTS_Baseline_PEPY__c = 20;

            Apttus_Config2__LineItem__c  optionLineItem1 = APTS_TestSetup.createLineItem(
                                                                priceList.Id, 
                                                                productConfig.Id, 
                                                                optionProduct.Id, 
                                                                pli.Id
                                                            );
            optionLineItem1.Apttus_Config2__LineType__c = ProposalLineItemTriggerHelper.OPTION;
            optionLineItem1.Apttus_Config2__Quantity__c = 2;
            optionLineItem1.APTS_Growth_Adjusted_Baseline__c = 100;
            optionLineItem1.Apttus_Config2__ExtendedPrice__c = 1000;
            optionLineItem1.Apttus_Config2__SellingTerm__c = 2 ;
            optionLineItem1.AG_Ramp_Line_Count__c = 2;
            optionLineItem1.APTS_Baseline_PEPY__c = 20;

            Apttus_Config2__LineItem__c  optionLineItem2 = APTS_TestSetup.createLineItem(
                                                                priceList.Id,
                                                                productConfig.Id,
                                                                optionProduct1.Id,
                                                                pli.Id
                                                            );
            optionLineItem2.Apttus_Config2__LineType__c = ProposalLineItemTriggerHelper.OPTION;
            optionLineItem2.Apttus_Config2__Quantity__c = 4;
            optionLineItem2.APTS_Growth_Adjusted_Baseline__c = 1000;
            optionLineItem2.Apttus_Config2__ExtendedPrice__c = 10000;
            optionLineItem2.Apttus_Config2__SellingTerm__c = 2 ;
            optionLineItem2.AG_Ramp_Line_Count__c = 2;
            optionLineItem2.APTS_Baseline_PEPY__c = 10;

            Apttus_Config2__LineItem__c  optionLineItem3 = APTS_TestSetup.createLineItem(
                                                                priceList.Id,
                                                                productConfig.Id,
                                                                optionProduct1.Id,
                                                                pli.Id
                                                            );
            optionLineItem3.Apttus_Config2__LineType__c = ProposalLineItemTriggerHelper.OPTION;
            optionLineItem3.Apttus_Config2__Quantity__c = 4;
            optionLineItem3.APTS_Growth_Adjusted_Baseline__c = 1000;
            optionLineItem3.Apttus_Config2__ExtendedPrice__c = 10000;
            optionLineItem3.Apttus_Config2__SellingTerm__c = 2 ;
            optionLineItem3.AG_Ramp_Line_Count__c = 2;
            optionLineItem1.APTS_Baseline_PEPY__c = 10;
            
            insert new List<Apttus_Config2__LineItem__c>{
                bunbleLineItem,
                optionLineItem,
                optionLineItem1,
                optionLineItem2,
                optionLineItem3
            };
            
            Apttus_Proposal__Proposal_Line_Item__c bundleProposalLineItem = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                subscriptionProduct.Id
                                                                            );
            bundleProposalLineItem.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            bundleProposalLineItem.Apttus_QPConfig__DerivedFromId__c = bunbleLineItem.Id;
            
            Apttus_Proposal__Proposal_Line_Item__c optionProposalLineItem = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                optionProduct.Id
                                                                            );
            optionProposalLineItem.Apttus_QPConfig__LineType__c = proposalLineItemTriggerHelper.OPTION;
            optionProposalLineItem.Apttus_QPConfig__PriceUom__c = ProposalLineItemTriggerHelper.PRICE_UOM_FSE;
            optionProposalLineItem.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            optionProposalLineItem.Apttus_QPConfig__DerivedFromId__c = optionLineItem.Id;
            optionProposalLineItem.Apttus_QPConfig__IsPrimaryRampLine__c = true;
            optionProposalLineItem.APTS_Year__c = 1;

            Apttus_Proposal__Proposal_Line_Item__c optionProposalLineItem1 = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                optionProduct.Id
                                                                            );
            optionProposalLineItem1.Apttus_QPConfig__LineType__c = proposalLineItemTriggerHelper.OPTION;
            optionProposalLineItem1.Apttus_QPConfig__PriceUom__c = ProposalLineItemTriggerHelper.PRICE_UOM_FSE;
            optionProposalLineItem1.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            optionProposalLineItem1.Apttus_QPConfig__DerivedFromId__c = optionLineItem1.Id;
            optionProposalLineItem1.APTS_Year__c = 2;

            Apttus_Proposal__Proposal_Line_Item__c optionProposalLineItem2 = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                optionProduct1.Id
                                                                            );
            optionProposalLineItem2.Apttus_QPConfig__LineType__c = proposalLineItemTriggerHelper.OPTION;
            optionProposalLineItem2.Apttus_QPConfig__PriceUom__c = ProposalLineItemTriggerHelper.PRICE_UOM_FSE;
            optionProposalLineItem2.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            optionProposalLineItem2.Apttus_QPConfig__IsPrimaryRampLine__c = true;
            optionProposalLineItem2.Apttus_QPConfig__DerivedFromId__c = optionLineItem2.Id;
            optionProposalLineItem2.APTS_Year__c = 1;

            Apttus_Proposal__Proposal_Line_Item__c optionProposalLineItem3 = APTS_TestSetup.getProposalLineItem(
                                                                                proposal.Id, 
                                                                                productConfig.Id, 
                                                                                optionProduct1.Id
                                                                            );
            optionProposalLineItem3.Apttus_QPConfig__LineType__c = proposalLineItemTriggerHelper.OPTION;
            optionProposalLineItem3.Apttus_QPConfig__PriceUom__c = ProposalLineItemTriggerHelper.PRICE_UOM_FSE;
            optionProposalLineItem3.Apttus_QPConfig__LineStatus__c = ProposalLineItemTriggerHelper.LINE_RENEWED;
            optionProposalLineItem3.Apttus_QPConfig__DerivedFromId__c = optionLineItem3.Id;
            optionProposalLineItem3.APTS_Year__c = 2;

            insert new List<Apttus_Proposal__Proposal_Line_Item__c>{
                bundleProposalLineItem,
                optionProposalLineItem, 
                optionProposalLineItem1, 
                optionProposalLineItem2,
                optionProposalLineItem3
            };
            
            ProposalLineItemTriggerHelper.pliToQuoteUpd(
                new map<Id, Apttus_Proposal__Proposal_Line_Item__c> { 
                    bundleProposalLineItem.Id => bundleProposalLineItem,
                    optionProposalLineItem.Id => optionProposalLineItem,
                    optionProposalLineItem1.Id => optionProposalLineItem1,
                    optionProposalLineItem2.Id => optionProposalLineItem2,
                    optionProposalLineItem3.Id => optionProposalLineItem3
                }
            );
        Test.stopTest();
    }
}