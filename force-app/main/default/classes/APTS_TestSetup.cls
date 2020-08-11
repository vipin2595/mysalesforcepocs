/*************************************************************************************************************
* @author Ruslan Vekua - aMind Solutions
* @CreatedDate 09/03/2018
* 
* Last Modified By - Ruslan Vekua
* @ModifiedDate 09/03/2018
* @Description: This class creates test data for apex test methods.
* @Change History:
        1. Ruslan Vekua 09/03/2018' - Create initial version
***************************************************************************************************************/
@IsTest
public class APTS_TestSetup {

   /* static {
        insert new Data_Management__c(SetupOwnerId=UserInfo.getOrganizationId(),
                                     Restrict_Account_Workflow_PB__c=true,
                                     Restrict_Opportunity_Workflow_PB__c=true,
                                     Restrict_Contact_Workflow_PB__c=true,
                                     Restrict_Case_Workflow_PB__c=true,
                                     Restrict_Agreement_Workflow_PB__c=true,
                                     Restrict_Quote_Workflow_PB__c=true,
                                     Restrict_Task_Workflow_PB__c=true,
                                     Restrict_User_Workflow_PB__c=true
                                     );
    
    }
*/
    
                                     
    public static Product2 createProduct(String name, String code) {
        return new Product2(
            Name = name,
            ProductCode = code,
            Apttus_Config2__Uom__c = 'Each',
            Apttus_Config2__Version__c = 1.00,
            Apttus_Config2__ConfigurationType__c = 'Standalone',
            isActive = true);
    }

    public static Apttus_Config2__PriceList__c createUSDPriceList(String name) {
        return new Apttus_Config2__PriceList__c(
            Name = name,
            Apttus_Config2__Active__c = true,
            CurrencyIsoCode = 'USD');
    }
    
    public static void AddExtension() 
    {
        Scout_Extension__c sc = new Scout_Extension__c();
        sc.Name = 'Scout Extension 1';
        sc.Product_Code__c = 'SW-SRS-USER-100';
        Insert sc;
        Scout_Extension__c sc1 = new Scout_Extension__c();
        sc1.Name = 'Scout Extension 2';
        sc1.Product_Code__c = 'SW-CON-PLAT-101';
        Insert sc1;
    }
    public static void AddPowerUser()
    {
        Power_Users__c pw = new Power_Users__c();
        pw.Name = 'System Administrator';
        Insert pw;
        Power_Users__c pw1 = new Power_Users__c();
        pw1.Name = 'Data Administrator';
        Insert pw1;
    } 
    public static void createInitialData() {
        Data_Management__c dm = Data_Management__c.getInstance(UserInfo.getOrganizationId());
        
        // 19/Dec/2019 release Test class failure fix: commenting the below line to fix the test class failures as part of the release.
        // if(dm == null) {
        
        dm.SetupOwnerId=UserInfo.getOrganizationId();
        dm.Restrict_Account_Workflow_PB__c=true;
        dm.Restrict_Opportunity_Workflow_PB__c=true;
        dm.Restrict_Contact_Workflow_PB__c=true;
        dm.Restrict_Case_Workflow_PB__c=true;
        dm.Restrict_Agreement_Workflow_PB__c=true;
        dm.Restrict_Quote_Workflow_PB__c=true;
        dm.Restrict_Task_Workflow_PB__c=true;
        dm.Restrict_User_Workflow_PB__c=true;
        dm.PPLA_Check__c=true;
        upsert dm;
        
        // 19/Dec/2019 release Test class failure fix: commenting the below line to fix the test class failures as part of the release.
        // } 
        
        Account acc = createAccount();
        acc.BillingCountry='United States';
        insert acc;
        Opportunity oppty = createOpportunity('WD Oppty', acc.Id);
        insert oppty;
        Product2 pr2 = createProduct('Product A', 'Product A');
        insert pr2;
        Apttus_Config2__PriceList__c pl = createUSDPriceList('WD Price List');
        insert pl;
        Apttus_Config2__ClassificationName__c cn = createCategory();
        insert cn;
        Apttus_Config2__ClassificationHierarchy__c ch = createCategoryHierarchy(cn.Id);        
        insert ch;
        Apttus_Config2__ClassificationHierarchy__c chSub = createSubCategoryHierarchy(cn.Id, ch.Id);
        insert chSub;
        Apttus_Config2__ProductClassification__c pclass = createProductClassification(pr2.Id, ch.Id);
        insert pclass;
        Apttus_Config2__PriceListCategory__c plc = createPriceListCategory(pl.Id, cn.Id);
        insert plc;
        Apttus_Config2__PriceListItem__c pli = createPriceListItem(pl.Id, pr2.Id);
        insert pli;
    }

    public static Apttus_Config2__ClassificationName__c createCategory() {
        return new Apttus_Config2__ClassificationName__c(
            Name = 'WD Category',
            Apttus_Config2__HierarchyLabel__c = 'WD Category Label',
            Apttus_Config2__Active__c = true,
            Apttus_Config2__Type__c = 'Offering');
    }

    public static User createSysAdminUser(String userName, String alias) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        return new User(
            Alias = alias,
            Email = 'test@test00023.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestLastName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = userName,
            Country__c = 'United States',
            Allow_Both_Pricer__c = false,
            BundleSelection__c = 'LDP',
            E_G__c = true,
            CommunityNickname=userName+'-11');
    }

    public static User createAEUser(String userName, String alias) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Account Executive'];
        return new User(
            Alias = alias,
            Email = 'test@test00024.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestAELastName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = userName,
            Country__c = 'United States',
            Allow_Both_Pricer__c = false,
            BundleSelection__c = 'LDP',
            E_G__c = true,
            CommunityNickname=userName+'-11');
    }

    public static Apttus_Proposal__Proposal__c createProposal(ID opptyId, ID priceListId) {
        Id recordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get(APTPS_Constants.RT_PROP_PROPOSAL).getRecordTypeId();
        return new Apttus_Proposal__Proposal__c(
            Apttus_Proposal__Proposal_Name__c = 'Test Proposal',
            Apttus_Proposal__Description__c = 'Test Description',
            Apttus_Proposal__Opportunity__c = opptyId,
            Apttus_QPConfig__PriceListId__c = priceListId,
            Apttus_Proposal__Primary__c = true,
            Apttus_Proposal__Approval_Stage__c = 'Draft',
            Apttus_Proposal__Proposal_Category__c = 'Proposal',
            Apttus_Proposal__ReadyToGenerate__c = true,
            Apttus_Proposal__ReadyToPresent__c = true,
            Apttus_Proposal__ExpectedStartDate__c = System.today(),
            Apttus_Proposal__ExpectedEndDate__c = System.today().addDays(30),
            APTS_E_G_Discount__c = 'No',
            Quote__c = 'Not Submitted',
            RecordTypeId = recordTypeId);
    }

    public static Apttus_Config2__ProductConfiguration__c createCart(ID proposalId, ID priceListId) {
        return new Apttus_Config2__ProductConfiguration__c(
            Name = 'Product Config - Test Proposal',
            Apttus_Config2__VersionNumber__c = 1,
            Apttus_Config2__SummaryGroupType__c = 'Category',
            Apttus_Config2__Status__c = 'Saved',
            Apttus_QPConfig__Proposald__c = proposalId,
            Apttus_Config2__BusinessObjectType__c = 'Proposal',
            Apttus_Config2__BusinessObjectId__c = proposalId,
            Apttus_Config2__BusinessObjectRefId__c = proposalId,
            Apttus_Config2__PriceListId__c = priceListId,
            Apttus_Config2__EffectivePriceListId__c = priceListId,
            Apttus_Config2__IsTransient__c = true,
            Apttus_Config2__IsPricePending__c = false,
            Apttus_Config2__ExpectedStartDate__c = System.today(),
            Apttus_Config2__ExpectedEndDate__c = System.today().addDays(30),
            CurrencyIsoCode = 'USD'
        ); 
    }

    public static Apttus_Config2__LineItem__c createLineItem(ID priceListId, ID cartId, ID product2Id, ID priceListItemId) {
        return new Apttus_Config2__LineItem__c(
            Apttus_Config2__LineNumber__c = 1,
            Apttus_Config2__PrimaryLineNumber__c = 1, 
            Apttus_Config2__LineType__c = 'Product/Service',
            Apttus_Config2__IsPrimaryLine__c = true, 
            Apttus_Config2__ItemSequence__c = 1,
            Apttus_Config2__Quantity__c = 1,
            Apttus_Config2__Comments__c = 'New Comment',
            Apttus_Config2__TotalQuantity__c = 1,
            Apttus_Config2__SellingTerm__c = 1,
            Apttus_Config2__DeltaPrice__c = 10,
            Apttus_Config2__ListPrice__c = 10,
            Apttus_Config2__ExtendedPrice__c = 10,
            Apttus_Config2__DeltaQuantity__c = 1,
            Apttus_Config2__SellingFrequency__c = 'One Time',
            Apttus_Config2__PriceListId__c = priceListId,
            Apttus_Config2__ConfigurationId__c = cartId,
            Apttus_Config2__ProductId__c = product2Id,
            Apttus_Config2__PriceListItemId__c = priceListItemId
        ,APTS_ProductRampBy__c = 3
        ,APTS_ProductRampPeriod__c = 'Yearly'
        ,APTS_PeriodNumber__c = 1
        ,ACV__c =  100
        ,ACV_List__c  =100
        ,ACV_List_Approved__c  =100
        ,APTS_ACV_Override__c=  100
        ,Apttus_Config2__PriceGroup__c = 'Price Ramp'
        ,Approved_ACV__c=  100
        ,APTS_Add_FSE_Adj_Applied__c  =100
        ,APTS_Add_FSE_Baseline__c  =100
        ,APTS_Additional_FSE_List_ACV__c  =100
        ,APTS_Additional_FSE_Net_ACV__c  =100
        ,APTS_Add_on_Adj_Applied__c  =100
        ,APTS_Add_On_Base_Price__c  =100
        ,APTS_Add_on_Adjustment_PCT__c  =15
        ,APTS_Adj_Baseline__c  =100
        ,Apttus_Config2__AdjustedPrice__c  =100
        ,Apttus_Config2__AdjustmentAmount__c  =15
        ,Apttus_Config2__AllocateGroupAdjustment__c  =TRUE
        ,Apttus_Config2__AllowManualAdjustment__c=  TRUE
        ,Apttus_Config2__AllowProration__c  =TRUE
        ,Apttus_Config2__AllowRemoval__c=  TRUE
        ,Assessment_Effort_Level__c  =15
        ,Apttus_Config2__AssetQuantity__c=  15
        ,Apttus_Config2__AutoRenew__c  =TRUE
        ,Apttus_Config2__AutoRenewalTerm__c=  15
        ,AACV_DR__c  =100
        ,APEPY__c  =100
        ,Apttus_Config2__BaseCost__c  =100
        ,Apttus_Config2__BaseCostOverride__c=  100
        ,Base_CPI__c  =100
        ,Apttus_Config2__BaseExtendedCost__c  =100
        ,Apttus_Config2__BaseExtendedPrice__c=  100
        ,APTS_Base_II__c  =100
        ,APTS_Baseline_ACV__c  =100
        ,APTS_Baseline_Adj_Applied__c  =100
        ,APTS_Baseline_Adjustment_PCT__c  =15
        ,APTS_Baseline_List_ACV__c=  100
        ,APTS_Baseline_Net_ACV__c  =100 
        ,APTS_Baseline_Other_Adjustment__c  =100 
        ,APTS_Baseline_Quantity__c  =15 
        ,APTS_Baseline_Reduction_FSE__c=  100 
        ,APTS_Baseline_Reduction_SKU__c  =100 
        ,Apttus_Config2__BasePrice__c  =100 
        ,Apttus_Config2__BasePriceOverride__c=  100 
        ,APTS_Base_Uplift_Amount__c  =100 
        ,APTS_Booking_Amount__c  =100 
        ,APTS_Booking_Amount_List__c  =100 
        ,Bundle_FSE__c  =15 
        ,Approved_Bundle_FSE__c=  15 
        ,Apttus_Config2__CollaborationParentLineNumber__c  =15 
        ,Apttus_Config2__CommitmentQuantity__c=  15 
        ,APTS_ContrDiscPerc__c  =15 
        ,Apttus_Config2__CopySourceBundleNumber__c  =15 
        ,Apttus_Config2__CopySourceLineNumber__c=  15 
        ,Apttus_Config2__CopySourceNumber__c=  15 
        ,Apttus_Config2__Cost__c=  100 
        ,APTS_CPI__c  =100 
        ,APTS_CPI_G__c  =15 
        ,APTS_CPI_NG__c=  15 
        ,APTS_CPI_Applicable__c  =TRUE 
        ,APTS_CPI_List_Add_FSE__c  =100 
        ,APTS_CPI_List_Baseline__c  =100 
        ,Apttus_Config2__Customizable__c  =TRUE 
        ,APTS_DeltaPercent__c  =15
        ,APTS_PEPY__c=  100 
        ,APTS_Drop_SKU_Line_Count__c  =15 
        ,APTS_Exclude_from_Expansion__c=  false 
        ,APTS_Non_Renewable__c  =TRUE 
        ,EYACV__c  =100 
        ,EYPEPY__c  =100 
        ,APTS_Add_FSE_Adjustment_PCT__c=  15 
        ,APTS_Expansion_Type__c=  null 
        ,Apttus_Config2__ExtendedCost__c  =100 
        ,Apttus_Config2__ExtendedQuantity__c=  15 
        ,AACV__c  =100 
        ,APTS_Final_Base_PEPY__c  =100 
        ,AG_SKU_Sales_ACV__c=  100 
        ,AG_SKU_TCV__c  =100 
        ,Financials_ACV__c  =100 
        ,Apttus_Config2__FlatOptionPrice__c=  100 
        ,Approved_FSE__c  =15 
        ,APTS_Final_Base_ACV__c  =100 
        ,Apttus_Config2__GroupAdjustmentPercent__c  =15 
        ,APTS_Group_Quantity__c=  15 
        ,APTS_Group_Quantity_Pricing__c=  TRUE 
        ,APTS_GroupTargetQuantity__c  =15 
        ,APTS_Growth__c=  15 
        ,Growth_Applied__c  =TRUE 
        ,APTS_Growth_Event__c  =15 
        ,Growth_Year__c=  15 
        ,Apttus_Config2__HasAttributes__c  =TRUE 
        ,Apttus_Config2__HasBaseProduct__c=  TRUE 
        ,Apttus_Config2__HasDefaults__c  =TRUE 
        ,Apttus_Config2__HasIncentives__c  =TRUE 
        ,Apttus_Config2__HasOptions__c  =TRUE 
        ,Apttus_Config2__HasTieredPrice__c  =TRUE 
        ,APTS_Headcount_Reduction_Line_Count__c=  15 
        ,Apttus_Config2__HideCopyAction__c  =TRUE 
        ,Apttus_Config2__HideInvoiceDisplay__c  =TRUE 
        ,Apttus_Config2__IncentiveAdjustmentAmount__c=100 
        ,Apttus_Config2__IncentiveBasePrice__c  =100 
        ,APTS_Incentive_Credit__c  =100 
        ,Apttus_Config2__IncentiveExtendedPrice__c  =100 
        ,APTS_Innovation_Index__c  =100 
        ,APTS_II_G__c  =100 
        ,APTS_II_NG__c  =100 
        ,APTS_II_Applicable__c  =TRUE 
        ,APTS_II_List_Add_FSE__c  =100 
        ,APTS_II_List_Baseline__c  =100 
        ,Apttus_Config2__IsAssetPricing__c  =TRUE 
        ,APTS_IsCustomPricePending__c=  TRUE 
        ,Apttus_Config2__IsCustomPricing__c=  TRUE 
        ,Apttus_Config2__IsHidden__c=  TRUE 
        ,APTS_IsLockedForFSEAdjustment__c  =TRUE 
        ,Apttus_Config2__IsOptional__c  =TRUE 
        ,Apttus_Config2__IsOptionRollupLine__c  =TRUE 
        ,APTS_Is_PEPY_Overridden__c=  TRUE 
        ,Apttus_Config2__IsPrimaryRampLine__c  =TRUE 
        ,Apttus_Config2__IsQuantityModifiable__c  =TRUE 
        ,Apttus_Config2__IsReadOnly__c  =TRUE 
        ,Apttus_Config2__IsSellingTermReadOnly__c  =TRUE 
        ,Apttus_Config2__IsUsageTierModifiable__c  =TRUE 
        ,APTS_LDP_Tooling_Lookup__c=  100 
        ,APTS_LimitedUse__c  =15 
        ,APTS_LimitedUsePercentApplied__c=TRUE 
        ,Line_Discount_Approved__c  =15
        ,Apttus_Config2__LineSequence__c  =15
        ,APTS_CPI_Rate__c  =15 
        ,APTS_Total_List_Price_Add_FSE__c  =100 
        ,APTS_II_Rate__c  =15 
        ,APTS_Uplift_List_Baseline__c=  100 
        ,APTS_Max_PEPY_Defined__c  =TRUE 
        ,APTS_Max_PEPY_Lookup__c  =100 
        ,Apttus_Config2__MaxPrice__c  =100 
        ,Apttus_Config2__MaxUsageQuantity__c  =15 
        ,Apttus_Config2__MinPrice__c=  100 
        ,Apttus_Config2__MinUsageQuantity__c=  15 
        ,APTS_Needs_Repricing__c  =TRUE 
        ,APTS_Net_Add_FSE_Baseline__c  =100 
        ,APTS_Net_Add_On_Price__c  =100 
        ,APTS_Net_Adj_Baseline__c  =100 
        ,Apttus_Config2__NetAdjustmentPercent__c=  15 
        ,Apttus_Config2__NetPrice__c=  100 
        ,Apttus_Config2__NetUnitPrice__c  =100 
        ,APTS_New_FSE__c  =15 
        ,Apttus_Config2__OptionCost__c  =100 
        ,Apttus_Config2__OptionPrice__c=  100 
        ,Apttus_Config2__OptionSequence__c  =15 
        ,APTS_Override_CPI_Rate__c=  15 
        ,APTS_Override_Innovation_Index_Rate__c=  15 
        ,ATPS_Override_Method_Baseline_ACV__c  ='Exit Year' 
        ,Apttus_Config2__ParentBundleNumber__c  =1 
        ,PCSM_Discounted_Rate__c  =100 
        ,PCSM_Rate__c  =100 
        ,PCSM_Term__c  =15 
        ,PEPY_Approved__c  =100 
        ,APTS_PEPY_Override__c  =100 
        ,Apttus_Config2__RelatedPercent__c  =15 
        ,APTS_PLI_ACV_Floor__c  =100 
        ,APTS_GA_Date__c  =date.newInstance(2025, 06, 25) 
        ,APTS_Pre_GA_Credit__c  =100 
        ,Apttus_Config2__PriceAdjustment__c=  100 
        ,Apttus_Config2__PriceAdjustmentAmount__c  =15 
        ,Apttus_Config2__PriceIncludedInBundle__c  =TRUE 
        ,Apttus_Config2__PriceMethod__c=  'Per Unit' 
        ,Apttus_Config2__PricingDate__c=  date.newInstance(2025, 06, 25) 
        ,apts_pricing_quantity__c=  100 
        ,Apttus_Config2__Term__c  =15
        ,APTS_Prior_Expansion_Quantity__c  =15 
        ,APTS_Product_Group_Sequence__c=  15 
        ,APTS_ProductRampEndDate__c=  date.newInstance(2028, 06, 25) 
        ,APTS_ProductRampStartDate__c  =date.newInstance(2025, 06, 25) 
        ,Apttus_Config2__ProductVersion__c=  15 
        ,APTS_Pro_CPI_After__c=15 
        ,APTS_Pro_CPI_Before_G__c  =15 
        ,APTS_Pro_CPI_Before_NG__c  =15 
        ,APTS_Pro_II_After__c  =15 
        ,APTS_Pro_II_Before_G__c=  15 
        ,APTS_Pro_II_Before_NG__c  =15 
        ,APTS_Pro_Uplift_After__c  =15 
        ,APTS_Pro_Uplift_Before__c  =15
        ,AG_Ramp_Line_Count__c  =15 
        ,Ramp_Months_SKU_Approved__c=  15 
        ,Apttus_Config2__RelatedAdjustmentAmount__c=  15 
        ,Apttus_Config2__RenewalAdjustmentAmount__c=  15 
        ,Apttus_Config2__RollupPriceToBundle__c=  TRUE 
        ,APTS_Root_End_Date__c  =date.newInstance(2028, 06, 25)
        ,APTS_Root_PN_CPI_Applicable__c=  TRUE 
        ,APTS_Root_PN_II_Rate__c  =15 
        ,APTS_Root_PN_Max_Uplift__c  =15 
        ,APTS_Root_Start_Date__c= date.newInstance(2025, 06, 25) 
        ,Sales_ACV__c  =100 
        ,APTS_Sibling_Payroll_Flag__c=  TRUE 
        ,APTS_Simple_ACV__c  =100 
        ,APTS_Simple_Net_ACV__c  =100 
        ,APTS_SKU_Additional_FSE_List_TCV__c=  100 
        ,APTS_SKU_Additional_FSE_Net_TCV__c  =100 
        ,APTS_SKU_Baseline_List_TCV__c  =100 
        ,APTS_SKU_Baseline_Net_TCV__c  =100 
        ,AG_SKU_Baseline_Other_Adjustment__c  =100 
        ,AG_SKU_Baseline_Reduction_FSE__c  =100 
        ,AG_SKU_Baseline_Reduction_SKU__c  =100 
        ,AG_SKU_CPI_Net_Baseline__c=  100 
        ,APTS_SKU_End_Date__c  =date.newInstance(2028, 06, 25) 
        ,AG_SKU_EY_Quantity__c  =15 
        ,AG_SKU_EY_Simple_Net_ACV__c=  100 
        ,AG_SKU_II_Net_Baseline__c  =100 
        ,APTS_SKU_List_ACV__c  =100 
        ,APTS_SKU_List_TCV__c  =100 
        ,AG_SKU_Quantity__c  =15 
        ,AG_SKU_Sales_Term__c  =15 
        ,APTS_SKU_Start_Date__c  =date.newInstance(2025, 06, 25) 
        ,AG_SKU_Term__c  =15 
        ,AG_SKU_Term_days__c  =15 
        ,Apttus_Config2__StartDate__c  =date.newInstance(2025, 06, 25) 
        ,Start_Date_Override__c=  date.newInstance(2025, 06, 25) 
        ,System_Calculated_Hours__c  =15 
        ,Apttus_Config2__Taxable__c  =TRUE 
        ,Apttus_Config2__TaxInclusive__c=  TRUE 
        ,APTS_TCV__c  =100 
        ,Approved_TCV__c  =100 
        ,Approved_Quote_Term__c=  15 
        ,Term_SKU_Approved__c  =15 
        ,APTS_Tools_Fee__c  =100 
        ,APTS_Total_Baseline_Reduction__c=  100 
        ,APTS_Total_Growth_FSE__c=  15 
        ,APTS_Total_List_Price_Baseline__c=  100 
        ,APTS_Total_Pricing_Quantity__c  =15
        ,APTS_Total_Uplift_Baseline__c  =100 
        ,APTS_Baseline_PEPY__c  =100 
        ,Apttus_Config2__UnitCostAdjustment__c  =100 
        ,Apttus_Config2__UnitPriceAdjustmentAuto__c=  100 
        ,Apttus_Config2__UnitPriceAdjustmentManual__c  =100 
        ,APTS_Uplift_Amount__c  =100
        );
    }

    public static Apttus_Config2__LineItem__c createOptionLineItem(ID priceListId, ID cartId, ID product2Id, ID priceListItemId, ID prodOptionComponentId, Id optionId){
        Apttus_Config2__LineItem__c lineItem = APTS_TestSetup.createLineItem(priceListId, cartId, product2Id, priceListItemId);
        lineItem.Apttus_Config2__StartDate__c = System.today().addDays(-15);
        lineItem.APTS_ProductRampStartDate__c = lineItem.Apttus_Config2__StartDate__c;
        lineItem.Apttus_Config2__EndDate__c = System.today().addYears(3);
        lineItem.APTS_ProductRampEndDate__c = lineItem.Apttus_Config2__EndDate__c;
        lineItem.APTS_ProductRampBy__c = 3;
        lineItem.Apttus_Config2__ListPrice__c = 100;
        lineItem.APTS_ProductRampPeriod__c = 'Yearly';
        lineItem.APTS_PeriodNumber__c = 1;
        lineItem.Apttus_Config2__SellingFrequency__c = 'Yearly';
        lineItem.Apttus_Config2__PriceUom__c = 'FSE';
        lineItem.Apttus_Config2__LineType__c = 'Option';
        lineItem.Apttus_Config2__OptionId__c = optionId;
        lineItem.Apttus_Config2__LineNumber__c = 1;
        lineItem.Apttus_Config2__PrimaryLineNumber__c = 2;
        lineItem.Apttus_Config2__ParentBundleNumber__c = 1;
        lineItem.Apttus_Config2__ProductOptionId__c = prodOptionComponentId;
        lineItem.Apttus_Config2__PricingStatus__c = 'Completed';
        lineItem.Apttus_Config2__IsPrimaryRampLine__c = true;
        lineItem.Apttus_Config2__NetPrice__c = 5000;
        lineItem.Apttus_Config2__AdjustedPrice__c = 5000;
        lineItem.Apttus_Config2__BaseExtendedPrice__c = 5000;
        lineItem.Apttus_Config2__BasePrice__c = 5000;
        lineItem.Apttus_Config2__DeltaPrice__c = 5000;
        lineItem.Apttus_Config2__ExtendedPrice__c = 5000;
        lineItem.APTS_ProductRampPeriod__c = 'Yearly';
        lineItem.ACV__c =   100;
        lineItem.ACV_List__c    =100;
        lineItem.ACV_List_Approved__c   =100;
        lineItem.APTS_ACV_Override__c=  100;
        lineItem.Apttus_Config2__PriceGroup__c = 'Price Ramp';
        lineItem.Approved_ACV__c=   100;
        lineItem.APTS_Add_FSE_Adj_Applied__c    =100;
        lineItem.APTS_Add_FSE_Baseline__c   =100;
        lineItem.APTS_Additional_FSE_List_ACV__c    =100;
        lineItem.APTS_Additional_FSE_Net_ACV__c =100;
        lineItem.APTS_Add_on_Adj_Applied__c =100;
        lineItem.APTS_Add_On_Base_Price__c  =100;
        lineItem.APTS_Add_on_Adjustment_PCT__c  =15;
        lineItem.APTS_Adj_Baseline__c   =100;
        lineItem.Apttus_Config2__AdjustedPrice__c   =100;
        lineItem.Apttus_Config2__AdjustmentAmount__c    =15;
        lineItem.Apttus_Config2__AllocateGroupAdjustment__c =TRUE;
        lineItem.Apttus_Config2__AllowManualAdjustment__c=  TRUE;
        lineItem.Apttus_Config2__AllowProration__c  =TRUE;
        lineItem.Apttus_Config2__AllowRemoval__c=   TRUE;
        lineItem.Assessment_Effort_Level__c =15;
        lineItem.Apttus_Config2__AssetQuantity__c=  15;
        lineItem.Apttus_Config2__AutoRenew__c   =TRUE;
        lineItem.Apttus_Config2__AutoRenewalTerm__c=    15;
        lineItem.AACV_DR__c =100;
        lineItem.APEPY__c   =100;
        lineItem.Apttus_Config2__BaseCost__c    =100;
        lineItem.Apttus_Config2__BaseCostOverride__c=   100;
        lineItem.Base_CPI__c    =100;
        lineItem.Apttus_Config2__BaseExtendedCost__c    =100;
        lineItem.Apttus_Config2__BaseExtendedPrice__c=  100;
        lineItem.APTS_Base_II__c    =100;
        lineItem.APTS_Baseline_ACV__c   =100;
        lineItem.APTS_Baseline_Adj_Applied__c   =100;
        lineItem.APTS_Baseline_Adjustment_PCT__c    =15;
        lineItem.APTS_Baseline_List_ACV__c= 100;
        lineItem.APTS_Baseline_Net_ACV__c   =100;
        lineItem.APTS_Baseline_Other_Adjustment__c  =100;
        lineItem.APTS_Baseline_Quantity__c  =15;
        lineItem.APTS_Baseline_Reduction_FSE__c=    100;
        lineItem.APTS_Baseline_Reduction_SKU__c =100;
        lineItem.Apttus_Config2__BasePrice__c   =100;
        lineItem.Apttus_Config2__BasePriceOverride__c=  100;
        lineItem.APTS_Base_Uplift_Amount__c =100;
        lineItem.APTS_Booking_Amount__c =100;
        lineItem.APTS_Booking_Amount_List__c    =100;
        lineItem.Bundle_FSE__c  =15;
        lineItem.Approved_Bundle_FSE__c=    15;
        lineItem.Apttus_Config2__CollaborationParentLineNumber__c   =15;
        lineItem.Apttus_Config2__CommitmentQuantity__c= 15;
        lineItem.APTS_ContrDiscPerc__c  =15;
        lineItem.Apttus_Config2__CopySourceBundleNumber__c  =15;
        lineItem.Apttus_Config2__CopySourceLineNumber__c=   15;
        lineItem.Apttus_Config2__CopySourceNumber__c=   15;
        lineItem.Apttus_Config2__Cost__c=   100;
        lineItem.APTS_CPI__c    =100;
        lineItem.APTS_CPI_G__c  =15;
        lineItem.APTS_CPI_NG__c=    15;
        lineItem.APTS_CPI_Applicable__c =TRUE;
        lineItem.APTS_CPI_List_Add_FSE__c   =100;
        lineItem.APTS_CPI_List_Baseline__c  =100;
        lineItem.Apttus_Config2__Customizable__c    =TRUE;
        lineItem.APTS_DeltaPercent__c   =15;
        lineItem.Apttus_Config2__DeltaPrice__c  =100;
        lineItem.Apttus_Config2__DeltaQuantity__c=  15;
        lineItem.APTS_PEPY__c=  100;
        lineItem.APTS_Drop_SKU_Line_Count__c    =15;
        lineItem.APTS_Exclude_from_Expansion__c=    false;
        lineItem.APTS_Non_Renewable__c  =TRUE;
        lineItem.EYACV__c   =100;
        lineItem.EYPEPY__c  =100;
        lineItem.APTS_Add_FSE_Adjustment_PCT__c=    15;
        lineItem.APTS_Expansion_Type__c=    null;
        lineItem.Apttus_Config2__ExtendedCost__c    =100;
        lineItem.Apttus_Config2__ExtendedQuantity__c=   15;
        lineItem.AACV__c    =100;
        lineItem.APTS_Final_Base_PEPY__c    =100;
        lineItem.AG_SKU_Sales_ACV__c=   100;
        lineItem.AG_SKU_TCV__c  =100;
        lineItem.Financials_ACV__c  =100;
        lineItem.Apttus_Config2__FlatOptionPrice__c=    100;
        lineItem.Approved_FSE__c    =15;
        lineItem.APTS_Final_Base_ACV__c =100;
        lineItem.Apttus_Config2__GroupAdjustmentPercent__c  =15;
        lineItem.APTS_Group_Quantity__c=    15;
        lineItem.APTS_Group_Quantity_Pricing__c=    TRUE;
        lineItem.APTS_GroupTargetQuantity__c    =15;
        lineItem.APTS_Growth__c=    15;
        lineItem.Growth_Applied__c  =TRUE;
        lineItem.APTS_Growth_Event__c   =15;
        lineItem.Growth_Year__c=    15;
        lineItem.Apttus_Config2__HasAttributes__c   =TRUE;
        lineItem.Apttus_Config2__HasBaseProduct__c= TRUE;
        lineItem.Apttus_Config2__HasDefaults__c =TRUE;
        lineItem.Apttus_Config2__HasIncentives__c   =TRUE;
        lineItem.Apttus_Config2__HasOptions__c  =TRUE;
        lineItem.Apttus_Config2__HasTieredPrice__c  =TRUE;
        lineItem.APTS_Headcount_Reduction_Line_Count__c=    15;
        lineItem.Apttus_Config2__HideCopyAction__c  =TRUE;
        lineItem.Apttus_Config2__HideInvoiceDisplay__c  =TRUE;
        lineItem.Apttus_Config2__IncentiveAdjustmentAmount__c=100;
        lineItem.Apttus_Config2__IncentiveBasePrice__c  =100;
        lineItem.APTS_Incentive_Credit__c   =100;
        lineItem.Apttus_Config2__IncentiveExtendedPrice__c  =100;
        lineItem.APTS_Innovation_Index__c   =100;
        lineItem.APTS_II_G__c   =100;
        lineItem.APTS_II_NG__c  =100;
        lineItem.APTS_II_Applicable__c  =TRUE;
        lineItem.APTS_II_List_Add_FSE__c    =100;
        lineItem.APTS_II_List_Baseline__c   =100;
        lineItem.Apttus_Config2__IsAssetPricing__c  =TRUE;
        lineItem.APTS_IsCustomPricePending__c=  TRUE;
        lineItem.Apttus_Config2__IsCustomPricing__c=    TRUE;
        lineItem.Apttus_Config2__IsHidden__c=   TRUE;
        lineItem.APTS_IsLockedForFSEAdjustment__c   =TRUE;
        lineItem.Apttus_Config2__IsOptional__c  =TRUE;
        lineItem.Apttus_Config2__IsOptionRollupLine__c  =TRUE;
        lineItem.APTS_Is_PEPY_Overridden__c=    TRUE;
        lineItem.Apttus_Config2__IsPrimaryRampLine__c   =TRUE;
        lineItem.Apttus_Config2__IsQuantityModifiable__c    =TRUE;
        lineItem.Apttus_Config2__IsReadOnly__c  =TRUE;
        lineItem.Apttus_Config2__IsSellingTermReadOnly__c   =TRUE;
        lineItem.Apttus_Config2__IsUsageTierModifiable__c   =TRUE;
        lineItem.APTS_LDP_Tooling_Lookup__c=    100;
        lineItem.APTS_LimitedUse__c =15;
        lineItem.APTS_LimitedUsePercentApplied__c=TRUE;
        lineItem.Line_Discount_Approved__c  =15;
        lineItem.Apttus_Config2__LineSequence__c    =15;
        lineItem.APTS_CPI_Rate__c   =15;
        lineItem.APTS_Total_List_Price_Add_FSE__c   =100;
        lineItem.APTS_II_Rate__c    =15;
        lineItem.APTS_Uplift_List_Baseline__c=  100;
        lineItem.APTS_Max_PEPY_Defined__c   =TRUE;
        lineItem.APTS_Max_PEPY_Lookup__c    =100;
        lineItem.Apttus_Config2__MaxPrice__c    =100;
        lineItem.Apttus_Config2__MaxUsageQuantity__c    =15;
        lineItem.Apttus_Config2__MinPrice__c=   100;
        lineItem.Apttus_Config2__MinUsageQuantity__c=   15;
        lineItem.APTS_Needs_Repricing__c    =TRUE;
        lineItem.APTS_Net_Add_FSE_Baseline__c   =100;
        lineItem.APTS_Net_Add_On_Price__c   =100;
        lineItem.APTS_Net_Adj_Baseline__c   =100;
        lineItem.Apttus_Config2__NetAdjustmentPercent__c=   15;
        lineItem.Apttus_Config2__NetPrice__c=   100;
        lineItem.Apttus_Config2__NetUnitPrice__c    =100;
        lineItem.APTS_New_FSE__c    =15;
        lineItem.Apttus_Config2__OptionCost__c  =100;
        lineItem.Apttus_Config2__OptionPrice__c=    100;
        lineItem.Apttus_Config2__OptionSequence__c  =15;
        lineItem.APTS_Override_CPI_Rate__c= 15;
        lineItem.APTS_Override_Innovation_Index_Rate__c=    15;
        lineItem.ATPS_Override_Method_Baseline_ACV__c   ='Exit Year';
        lineItem.Apttus_Config2__ParentBundleNumber__c  =1;
        lineItem.PCSM_Discounted_Rate__c    =100;
        lineItem.PCSM_Rate__c   =100;
        lineItem.PCSM_Term__c   =15;
        lineItem.PEPY_Approved__c   =100;
        lineItem.APTS_PEPY_Override__c  =100;
        lineItem.Apttus_Config2__RelatedPercent__c  =15;
        lineItem.APTS_PLI_ACV_Floor__c  =100;
        lineItem.APTS_GA_Date__c    =date.newInstance(2025, 06, 25);
        lineItem.APTS_Pre_GA_Credit__c  =100;
        lineItem.Apttus_Config2__PriceAdjustment__c=    100;
        lineItem.Apttus_Config2__PriceAdjustmentAmount__c   =15;
        lineItem.Apttus_Config2__PriceIncludedInBundle__c   =TRUE;
        lineItem.Apttus_Config2__PriceMethod__c=    'Per Unit';
        lineItem.apts_pricing_quantity__c=  100;
        lineItem.Apttus_Config2__Term__c    =15;
        lineItem.APTS_Prior_Expansion_Quantity__c   =15;
        lineItem.APTS_Product_Group_Sequence__c=    15;
        lineItem.Apttus_Config2__ProductVersion__c= 15;
        lineItem.APTS_Pro_CPI_After__c=15;
        lineItem.APTS_Pro_CPI_Before_G__c   =15;
        lineItem.APTS_Pro_CPI_Before_NG__c  =15;
        lineItem.APTS_Pro_II_After__c   =15;
        lineItem.APTS_Pro_II_Before_G__c=   15;
        lineItem.APTS_Pro_II_Before_NG__c   =15;
        lineItem.APTS_Pro_Uplift_After__c   =15;
        lineItem.APTS_Pro_Uplift_Before__c  =15;
        lineItem.Apttus_Config2__Quantity__c    =15;
        lineItem.AG_Ramp_Line_Count__c  =15;
        lineItem.Ramp_Months_SKU_Approved__c=   15;
        lineItem.Apttus_Config2__RelatedAdjustmentAmount__c=    15;
        lineItem.Apttus_Config2__RenewalAdjustmentAmount__c=    15;
        lineItem.Apttus_Config2__RollupPriceToBundle__c=    TRUE;
        lineItem.APTS_Root_PN_CPI_Applicable__c=    TRUE;
        lineItem.APTS_Root_PN_II_Rate__c    =15;
        lineItem.APTS_Root_PN_Max_Uplift__c =15;
        lineItem.Sales_ACV__c   =100;
        lineItem.Apttus_Config2__SellingTerm__c=    15;
        lineItem.APTS_Sibling_Payroll_Flag__c=  TRUE;
        lineItem.APTS_Simple_ACV__c =100;
        lineItem.APTS_Simple_Net_ACV__c =100;
        lineItem.APTS_SKU_Additional_FSE_List_TCV__c=   100;
        lineItem.APTS_SKU_Additional_FSE_Net_TCV__c =100;
        lineItem.APTS_SKU_Baseline_List_TCV__c  =100;
        lineItem.APTS_SKU_Baseline_Net_TCV__c   =100;
        lineItem.AG_SKU_Baseline_Other_Adjustment__c    =100;
        lineItem.AG_SKU_Baseline_Reduction_FSE__c   =100;
        lineItem.AG_SKU_Baseline_Reduction_SKU__c   =100;
        lineItem.AG_SKU_CPI_Net_Baseline__c=    100;
        lineItem.AG_SKU_EY_Quantity__c  =15;
        lineItem.AG_SKU_EY_Simple_Net_ACV__c=   100;
        lineItem.AG_SKU_II_Net_Baseline__c  =100;
        lineItem.APTS_SKU_List_ACV__c   =100;
        lineItem.APTS_SKU_List_TCV__c   =100;
        lineItem.AG_SKU_Quantity__c =15;
        lineItem.AG_SKU_Sales_Term__c   =15;
        lineItem.AG_SKU_Term__c =15;
        lineItem.AG_SKU_Term_days__c    =15;
        lineItem.System_Calculated_Hours__c =15;
        lineItem.Apttus_Config2__Taxable__c =TRUE;
        lineItem.Apttus_Config2__TaxInclusive__c=   TRUE;
        lineItem.APTS_TCV__c    =100;
        lineItem.Approved_TCV__c    =100;
        lineItem.Approved_Quote_Term__c=    15;
        lineItem.Term_SKU_Approved__c   =15;
        lineItem.APTS_Tools_Fee__c  =100;
        lineItem.APTS_Total_Baseline_Reduction__c=  100;
        lineItem.APTS_Total_Growth_FSE__c=  15;
        lineItem.APTS_Total_List_Price_Baseline__c= 100;
        lineItem.APTS_Total_Pricing_Quantity__c =15;
        lineItem.Apttus_Config2__TotalQuantity__c   =15;
        lineItem.APTS_Total_Uplift_Baseline__c  =100;
        lineItem.APTS_Baseline_PEPY__c  =100;
        lineItem.Apttus_Config2__UnitCostAdjustment__c  =100;
        lineItem.Apttus_Config2__UnitPriceAdjustmentAuto__c=    100;
        lineItem.Apttus_Config2__UnitPriceAdjustmentManual__c   =100;
        lineItem.APTS_Uplift_Amount__c  =100;
        return lineItem;
    }
  
    public static Apttus_Config2__AssetLineItem__c createBundleAssetLineItem(ID priceListId, ID product2Id, ID priceListItemId) {
        return new Apttus_Config2__AssetLineItem__c(
            Apttus_Config2__LineNumber__c = 1,
            Apttus_Config2__PrimaryLineNumber__c = 1,
            Apttus_Config2__LineType__c = 'Product/Service',
            Apttus_Config2__IsPrimaryLine__c = true,
            Apttus_Config2__ItemSequence__c = 1,
            Apttus_Config2__Quantity__c = 1,
            Apttus_Config2__PriceListId__c = priceListId,
            Apttus_Config2__ProductId__c = product2Id,
            Apttus_Config2__PriceListItemId__c = priceListItemId,
            Apttus_Config2__StartDate__c = System.today(), 
            Apttus_Config2__EndDate__c = System.today().addDays(30)
        );
    }    

    public static Apttus_Config2__AssetLineItem__c createOptionAssetLineItem(ID priceListId, ID product2Id, ID priceListItemId, ID bundleAssetId) {
        return new Apttus_Config2__AssetLineItem__c(
            Apttus_Config2__LineNumber__c = 1,
            Apttus_Config2__PrimaryLineNumber__c = 1,
            Apttus_Config2__LineType__c = 'Option',
            Apttus_Config2__BundleAssetId__c = bundleAssetId,
            Apttus_Config2__IsPrimaryLine__c = true,
            Apttus_Config2__ItemSequence__c = 2,
            Apttus_Config2__Quantity__c = 1,
            Apttus_Config2__PriceListId__c = priceListId,
            Apttus_Config2__ProductId__c = product2Id,
            Apttus_Config2__PriceListItemId__c = priceListItemId,
            Apttus_Config2__StartDate__c = System.today(), 
            Apttus_Config2__EndDate__c = System.today().addDays(30)
        );
    }      


    public static Apttus__APTS_Agreement__c createAgreement(ID accountId, ID opptyId) {
        return new Apttus__APTS_Agreement__c(
            name = 'testAgreement',
            Apttus__Account__c = accountId,
            Apttus__Related_Opportunity__c = opptyId,
            State_of_Incorporation__c = 'CA',
            Apttus__Contract_Start_Date__c = Date.Today(),
            CurrencyIsoCode = 'USD'
        );
    }    

    public static Apttus__AgreementLineItem__c createAgreementLineItem(ID agreementId, ID product2Id) {
        return new Apttus__AgreementLineItem__c(
            Apttus__AgreementId__c = agreementId,
            Apttus__ProductId__c = product2Id,
            Unit_Price__c = 70,  
            Quantity_custom__c = 86,
            Apts_Term_End_Date__c=null
        );
    }

    public static Opportunity createOpportunity(String name, ID accountId) {
        return new Opportunity(
            AccountId = accountId,
            Name = name,
            CloseDate = System.today().addDays(30),
            StageName = 'First Call',
            Probability = 0,
            Amount = 0);
    }

    public static Account createAccount() {
        return new Account(Name = 'Test Account');
    }

    public static Apttus_Config2__ClassificationHierarchy__c createCategoryHierarchy(final ID categoryId) {
        return new Apttus_Config2__ClassificationHierarchy__c(
            Name = 'Test Category',
            Apttus_Config2__Label__c = 'Test Category',
            Apttus_Config2__Left__c = 1,
            Apttus_Config2__Right__c = 4,
            Apttus_Config2__Level__c = 0,
            Apttus_Config2__IsHidden__c = false,
            Apttus_Config2__HierarchyId__c = categoryId,
            Apttus_Config2__Modifiable__c = true,
            Apttus_Config2__MinOptions__c = 1.00000,
            Apttus_Config2__MaxOptions__c = 1.00000,
            Apttus_Config2__IncludeInTotalsView__c = true,
            Apttus_Config2__Description__c = 'Desc Test');
    }

    public static Apttus_Config2__ClassificationHierarchy__c createSubCategoryHierarchy(final ID categoryId, final ID categoryHierarchyId) {
        return new Apttus_Config2__ClassificationHierarchy__c(
            Name = 'Test Category Sub',
            Apttus_Config2__Label__c = 'Test Category Sub',
            Apttus_Config2__Left__c = 2,
            Apttus_Config2__Right__c = 3,
            Apttus_Config2__Level__c = 1,
            Apttus_Config2__IsHidden__c = false,
            Apttus_Config2__HierarchyId__c = categoryId,
            Apttus_Config2__PrimordialId__c = categoryHierarchyId,
            Apttus_Config2__AncestorId__c = categoryHierarchyId,
            Apttus_Config2__Modifiable__c = true,
            Apttus_Config2__MinOptions__c = 1.00000,
            Apttus_Config2__MaxOptions__c = 1.00000,
            Apttus_Config2__IncludeInTotalsView__c = true);
    }

    public static Apttus_Config2__ProductClassification__c createProductClassification(final ID product2Id, final ID categoryHierarchyId) {
        return new Apttus_Config2__ProductClassification__c(
            Apttus_Config2__ClassificationId__c = categoryHierarchyId,
            Apttus_Config2__ProductId__c = product2Id,
            Apttus_Config2__Modifiable__c = true,
            Apttus_Config2__MinQuantity__c = 0,
            Apttus_Config2__MaxQuantity__c = 1.00000,
            Apttus_Config2__DefaultQuantity__c = 1.00000);
    }

    public static Apttus_Config2__PriceListCategory__c createPriceListCategory(final ID priceListId, final ID categoryId) {
        return new Apttus_Config2__PriceListCategory__c(
            Apttus_Config2__PriceListId__c = priceListId,
            Apttus_Config2__HierarchyId__c = categoryId,
            Apttus_Config2__Sequence__c = 1
        );
    }

    public static Apttus_Config2__PriceListItem__c createPriceListItem(final ID priceListId, final ID product2Id) {
        return new Apttus_Config2__PriceListItem__c(
            Apttus_Config2__ProductId__c = product2Id,
            Apttus_Config2__PriceListId__c = priceListId,
            Apttus_Config2__ChargeType__c = 'Standard Price',
            Apttus_Config2__PriceType__c = 'One Time',
            Apttus_Config2__PriceUom__c = 'Each',
            Apttus_Config2__ListPrice__c = 1000,
            Apttus_Config2__PriceMethod__c = 'Per Unit',
            Apttus_Config2__Active__c = true,
            Apttus_Config2__Frequency__c = 'Monthly');
    }

    public static Contact createContact(Id accountId){
        return new Contact(
            LastName = 'Test Contact',
            AccountId = accountId,
            Contact_Status__c = 'Active'
        );
    }

    public static void createAndInsertCustomSettings(){
        List<APTS_String_Constants__c> scs = new List<APTS_String_Constants__c>();
        scs.add(new APTS_String_Constants__c(Name='RT_PROP_PROPOSAL', Value__c='Proposal'));
        scs.add(new APTS_String_Constants__c(Name='LE', Value__c='Large Enterprise'));
        scs.add(new APTS_String_Constants__c(Name='LDP', Value__c='Lifecycle Deployment Program'));
        scs.add(new APTS_String_Constants__c(Name='QUALIFIED', Value__c='Qualified'));
        scs.add(new APTS_String_Constants__c(Name='NO', Value__c='No'));
        scs.add(new APTS_String_Constants__c(Name='PRICE_UOM_FSE', Value__c='FSE'));
        scs.add(new APTS_String_Constants__c(Name='RT_PROP_SUBSCR', Value__c='Subscription'));
        scs.add(new APTS_String_Constants__c(Name='RT_PROP_CONSULTING', Value__c='Consulting'));
        scs.add(new APTS_String_Constants__c(Name='RT_PROP_EDUCATION', Value__c='Education'));
        scs.add(new APTS_String_Constants__c(Name='RT_AGMT_SUBSCR', Value__c='Subscription'));
        scs.add(new APTS_String_Constants__c(Name='RT_AGMT_CONSULTING', Value__c='Consulting'));
        scs.add(new APTS_String_Constants__c(Name='RT_AGMT_TRAINING', Value__c='Training'));
        scs.add(new APTS_String_Constants__c(Name='RT_AGMT_PROPOSAL', Value__c='Proposal'));
        scs.add(new APTS_String_Constants__c(Name='OVERRIDE_VALUE', Value__c='Override'));
        scs.add(new APTS_String_Constants__c(Name='EXIT_YEAR', Value__c='Exit Year'));
        scs.add(new APTS_String_Constants__c(Name='AVERAGE', Value__c='Average'));
        scs.add(new APTS_String_Constants__c(Name='WORKER_CATEGORIES_ITEMS', Value__c='Worker Categories Items'));
        scs.add(new APTS_String_Constants__c(Name='APPROVED', Value__c='Approved'));
        insert scs;
    }

    public static void createAndInsertBaseDataFieldMapping() {
        List<APTS_BaseData_Field_Mapping__c> baseDataFiledMapping = new List<APTS_BaseData_Field_Mapping__c>();
        
        baseDataFiledMapping.add(new APTS_BaseData_Field_Mapping__c(Name = 'Asset Baseline ACV', 
            APTS_Source_Object__c ='Asset Line Item', 
            APTS_Active__c=true, 
            APTS_Source_Fields__c ='APTS_Final_Base_ACV__c', 
            APTS_Target_Field_Type__c='Decimal', 
            APTS_Target_Field__c='APTS_Baseline_ACV__c', 
            APTS_Source_Field_Expr__c='APTS_Final_Base_ACV__c'));

        baseDataFiledMapping.add(new APTS_BaseData_Field_Mapping__c(Name = 'ACV Floor', 
            APTS_Source_Object__c = 'Price List Item', 
            APTS_Active__c=true, 
            APTS_Source_Fields__c ='APTS_ACV_Floor__c', 
            APTS_Target_Field_Type__c='Decimal', 
            APTS_Target_Field__c='APTS_PLI_ACV_Floor__c', 
            APTS_Source_Field_Expr__c='APTS_ACV_Floor__c'));
        
        baseDataFiledMapping.add(new APTS_BaseData_Field_Mapping__c(Name = 'CPI Applicable', 
            APTS_Source_Object__c = 'Price List Item', 
            APTS_Active__c=true, 
            APTS_Source_Fields__c ='APTS_CPI_Applicable__c', 
            APTS_Target_Field_Type__c='Boolean', 
            APTS_Target_Field__c='APTS_CPI_Applicable__c', 
            APTS_Source_Field_Expr__c='APTS_CPI_Applicable__c'));

        baseDataFiledMapping.add(new APTS_BaseData_Field_Mapping__c(Name = 'PLI GA Date', 
            APTS_Source_Object__c = 'Price List Item', 
            APTS_Active__c=true, 
            APTS_Source_Fields__c ='APTS_GA_Date__c', 
            APTS_Target_Field_Type__c='Date', 
            APTS_Target_Field__c='APTS_GA_Date__c', 
            APTS_Source_Field_Expr__c='APTS_GA_Date__c'));

        insert baseDataFiledMapping;
    }
    
    public static void createAndInsertBigQuoteCustomSettings(){
        APTS_BigQuoteSettings__c bqs = new APTS_BigQuoteSettings__c();
        bqs.Name = 'Primary Settings';
        bqs.APTS_TotalNOLineItems__c = 1;
        insert bqs;
    }

    public static void createAndInsertPricingCustomSettings(){
        APTS_ConfigPricingProperties__c cpp = new APTS_ConfigPricingProperties__c();
        cpp.Name = 'System Properties';
        cpp.APTS_CheckAdjustmentPricingStatusTimeout__c = 5000;
        cpp.APTS_CheckBasePricePricingStatusTimeout__c = 15000;
        cpp.APTS_Large_Cart_Threshold__c = 2;
        cpp.APTS_NumberOfItemsPerRepriceCall__c = 2;
        cpp.APTS_RepriceEveryPrimaryLine__c = false;
        cpp.APTS_WorkerCountEditDelay__c = 1000;
        insert cpp;
    }

    public static void createAndInsertApttusCustomSettings() {
        Apttus_Config2__ConfigSystemProperties__c csp = new Apttus_Config2__ConfigSystemProperties__c();
        csp.Name = 'System Properties';
        csp.Apttus_Config2__ViewCartPage__c = 'Apttus_Config2__CartDetailView';
        csp.Apttus_Config2__ProductTotalingHierarchy__c = 'DO_NOT_USE__c';
        csp.Apttus_Config2__TotalingGroupType__c = 'Product';
        Insert csp;

        Apttus_Config2__ConfigCustomClasses__c ccc = new Apttus_Config2__ConfigCustomClasses__c();
        ccc.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
        ccc.Apttus_Config2__ValidationCallbackClass__c = 'APTPS_ValidateLinesCallback';
        ccc.Name = 'System Properties';
        insert ccc;
    }

    public static void createAndInsertCurrencyPriceListMappingCS(String name) {
        APTS_currency_to_price_list_mapping__c csp = new APTS_currency_to_price_list_mapping__c();
        csp.Name = name == null ? 'Workday pricelist' : name;
        csp.Currency__c = 'USD';
        csp.Is_Default__c = true;
        Insert csp;
    }

    public static void createAndInsertLineItemCustomSettings(){
        List<Apttus_Config2__ConfigLineItemCustomFields__c> clicfs = new List<Apttus_Config2__ConfigLineItemCustomFields__c>();
        Apttus_Config2__ConfigLineItemCustomFields__c clicf1 = new Apttus_Config2__ConfigLineItemCustomFields__c();
        clicf1.Name = 'S1';
        clicf1.Apttus_Config2__CustomFieldNames__c = 'Apttus_Config2__ListPrice__c,EYACV__c,EYPEPY__c,Financials_ACV__c, APTS_LDP_Tooling_Lookup__c, Apttus_Config2__AssetQuantity__c, APTS_Floor_List__c, APTS_Year__c, APTS_Baseline_ACV__c, APTS_Baseline_PEPY__c, APTS_CPI_Rate__c';
        clicf1.Apttus_Config2__CustomFieldNames2__c = 'Apttus_Config2__ExtendedPrice__c,AACV_DR__c,AACV__c,AG_Ramp_Line_Count__c,AG_SKU_EY_Quantity__c,AG_SKU_EY_Simple_Net_ACV__c,APTS_Baseline_Reduction_SKU__c';
        clicf1.Apttus_Config2__CustomFieldNames3__c = 'AG_SKU_Quantity__c,AG_SKU_Sales_ACV__c,AG_SKU_Sales_Term__c,AG_SKU_TCV__c,AG_SKU_Term_days__c,AG_SKU_Term__c,APEPY__c,APTS_Adj_Baseline__c,APTS_Baseline_Reduction_FSE__c, APTS_End_Year__c,APTS_CPI_Applicable__c';
        clicf1.Apttus_Config2__CustomFieldNames4__c = 'APTS_CPI__c,APTS_DeltaPercent__c,APTS_Innovation_Index__c,APTS_LDP_Tooling__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.APTS_OpportunityType__c,APTS_ACV_Floor_Applicable__c';
        clicf1.Apttus_Config2__CustomFieldNames5__c = 'Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.APTS_Annual_Fee_Structure__c,APTS_Simple_ACV__c,APTS_Simple_Net_ACV__c,APTS_SKU_End_Date__c,APTS_SKU_Start_Date__c,APTS_II_Rate__c';
        clicfs.add(clicf1);
        Apttus_Config2__ConfigLineItemCustomFields__c clicf2 = new Apttus_Config2__ConfigLineItemCustomFields__c();
        clicf2.Name = 'S2';
        clicf2.Apttus_Config2__CustomFieldNames__c = 'APTS_Total_List_Price_Baseline__c,APTS_Expansion_Quantity__c, Apttus_Config2__ChargeType__c, APTS_Override_Method_Baseline_PEPY__c,APTS_DMB_PEPY__c,APTS_PEPY_Override__c,APTS_Max_PEPY__c,ATPS_Override_Method_Baseline_ACV__c,APTS_Add_FSE_Adjustment_PCT__c';
        clicf2.Apttus_Config2__CustomFieldNames2__c = 'APTS_II_Applicable__c, APTS_Selling_Term_days__c, APTS_Final_Base_ACV__c, APTS_Final_Base_PEPY__c,APTS_Baseline_ACV__c, APTS_DeltaPercent__c, APTS_Total_Baseline_Reduction__c,APTS_Tooling_Fee_Applicable__c';
        clicf2.Apttus_Config2__CustomFieldNames3__c = 'APTS_Group_Quantity__c, APTS_Group_Quantity_Pricing__c,APTS_Add_FSE_Baseline__c, APTS_Baseline_Other_Adjustment__c, APTS_Net_Adj_Baseline__c, APTS_CPI_List_Baseline__c, APTS_Net_Add_On_Price__c, APTS_Net_Add_FSE_Baseline__c';
        clicf2.Apttus_Config2__CustomFieldNames4__c = 'APTS_Root_Line_Status__c, APTS_Root_PN_CPI_Applicable__c, APTS_PN_CPI_Applicable__c, APTS_Root_PN_II_Rate__c, APTS_PN_II_Rate__c, APTS_Root_PN_Max_Uplift__c, APTS_PN_Max_Uplift__c, APTS_II_List_Baseline__c, APTS_Baseline_Adjustment_PCT__c';
        clicf2.Apttus_Config2__CustomFieldNames5__c = 'APTS_Root_Start_Date__c, APTS_Root_End_Date__c, APTS_Add_On_Base_Price__c, APTS_Configuration_Type__c, APTS_ACV_Override__c, APTS_CPI_List_Add_FSE__c, APTS_II_List_Add_FSE__c, APTS_Total_List_Price_Add_FSE__c';
        clicfs.add(clicf2);
        Apttus_Config2__ConfigLineItemCustomFields__c clicf3 = new Apttus_Config2__ConfigLineItemCustomFields__c();
        clicf3.Name = 'S3';
        clicf3.Apttus_Config2__CustomFieldNames__c = 'APTS_SKU_Additional_FSE_List_TCV__c,APTS_SKU_Baseline_Net_TCV__c,APTS_SKU_Additional_FSE_Net_TCV__c,AG_SKU_CPI_Net_Baseline__c,AG_SKU_II_Net_Baseline__c';
        clicf3.Apttus_Config2__CustomFieldNames2__c = 'APTS_ProductRampStartDate__c,APTS_ProductRampEndDate__c,APTS_Baseline_List_ACV__c,APTS_Baseline_Net_ACV__c,APTS_Additional_FSE_List_ACV__c,APTS_Additional_FSE_Net_ACV__c';
        clicf3.Apttus_Config2__CustomFieldNames3__c = 'APTS_Total_Pricing_Quantity__c,Option_Code__c,APTS_CPI_Rate__c,APTS_II_Rate__c';
        clicf3.Apttus_Config2__CustomFieldNames4__c = 'APTS_IsCustomPricePending__c, APTS_SKU_List_TCV__c, APTS_Is_Line_Exit_Year__c, EYACV__c, AACV__c, ATPS_Override_Method_Baseline_ACV__c, APTS_Max_PEPY__c, APTS_Final_Method_Baseline_PEPY__c';
        clicf3.Apttus_Config2__CustomFieldNames5__c = 'APTS_Final_Base_ACV__c,APTS_Final_Method_Baseline_ACV__c, APTS_ACV_Override__c, APTS_Final_Base_PEPY__c, APEPY__c, EYPEPY__c, APTS_Override_Method_Baseline_PEPY__c, APTS_PEPY_Override__c, APTS_SKU_Baseline_List_TCV__c, AG_SKU_Term__c';
        clicfs.add(clicf3);
        Apttus_Config2__ConfigLineItemCustomFields__c clicf4 = new Apttus_Config2__ConfigLineItemCustomFields__c();
        clicf4.Name = 'S4';
        clicf4.Apttus_Config2__CustomFieldNames__c = 'APTS_Period_Ramp_After__c,APTS_Period_Ramp_Before__c, APTS_Period_Pre_GA__c,APTS_SKU_End_Year__c,APTS_Root_Term__c';
        clicf4.Apttus_Config2__CustomFieldNames2__c = 'APTS_Product_Group_Sequence__c,APTS_E_G_Discount__c,APTS_EG_Discount_Applicable__c,APTS_Max_PEPY_Defined__c,APTS_Max_PEPY_Lookup__c';
        clicf4.Apttus_Config2__CustomFieldNames3__c = 'APTS_Worker_Report__c,APTS_ProductGroup__c,APTS_Worker_Report_FSE__c';
        clicf4.Apttus_Config2__CustomFieldNames4__c = 'APTS_Product_Pricing_UOM__c, APTS_Uplift_Amount__c, APTS_Uplift_Rate__c,APTS_Uplift_first_Year__c,APTS_Base_Uplift_Amount__c, APTS_Pro_Uplift_Before__c, APTS_Pro_Uplift_After__c, APTS_Minimum_Sales_Term__c, APTS_Year__c';
        clicf4.Apttus_Config2__CustomFieldNames5__c = 'APTS_End_Year__c, Apttus_Config2__EndDate__c,APTS_Is_Renewed__c,APTS_Initial_Primary_Line_Status__c';
        clicfs.add(clicf4);
        Apttus_Config2__ConfigLineItemCustomFields__c clicf5 = new Apttus_Config2__ConfigLineItemCustomFields__c();
        clicf5.Name = 'S5';
        clicf5.Apttus_Config2__CustomFieldNames__c = 'Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.APTS_Business_Model__c,Apttus_Config2__StartDate__c,APTS_Product_GA_Date__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedEndDate__c';
        clicf5.Apttus_Config2__CustomFieldNames2__c = 'APTS_FSE_Adjusted_Type__c, APTS_GroupStatus__c,APTS_Product_Config_Start_Date__c';
        clicf5.Apttus_Config2__CustomFieldNames3__c = 'APTS_LimitedUse__c,APTS_LimitedUsePercentApplied__c';
        clicf5.Apttus_Config2__CustomFieldNames4__c = 'APTS_FSECalculateType__c,APTS_GrowthStatus__c,APTS_GrowthValue__c,APTS_GroupTargetQuantity__c';
        clicf5.Apttus_Config2__CustomFieldNames5__c = 'APTS_ProductRampBy__c, APTS_ProductRampPeriod__c, APTS_Growth__c, APTS_PeriodNumber__c,APTS_Initial_StartDate__c,APTS_Initial_EndDate__c';
        clicfs.add(clicf5);
        Apttus_Config2__ConfigLineItemCustomFields__c clicf6 = new Apttus_Config2__ConfigLineItemCustomFields__c();
        clicf6.Name = 'S6';
        clicf6.Apttus_Config2__CustomFieldNames2__c = 'APTS_Add_FSE_AdjType_Applied__c,APTS_Add_FSE_Adjustment_PCT__c,APTS_Add_FSE_Adj_Applied__c';
        clicf6.Apttus_Config2__CustomFieldNames3__c = 'APTS_Add_on_Adj_Applied__c,APTS_Add_on_Adjustment_PCT__c,APTS_Add_on_AdjType_Applied__c,APTS_Baseline_Adj_Applied__c,APTS_Baseline_AdjType_Applied__c, APTS_Baseline_Other_Adjustment__c';
        clicf6.Apttus_Config2__CustomFieldNames4__c = 'APTS_Related_Asset_Line_Item__c,APTS_Baseline_Quantity__c';
        clicfs.add(clicf6);
        Apttus_Config2__ConfigLineItemCustomFields__c clicf7 = new Apttus_Config2__ConfigLineItemCustomFields__c();
        clicf7.Name = 'S7';
        clicf7.Apttus_Config2__CustomFieldNames__c = 'APTS_Booking_Amount__c,Bundle_FSE__c,Category_Name__c,Exlude_from_translations__c,APTS_Needs_Repricing__c,Opportunity_Record_Type__c,PCSM_Discounted_Rate__c,PCSM_Rate__c,PCSM_Term__c,Pricer__c,GA_Date__c,Apttus_Config2__OptionId__r.Name';
        clicf7.Apttus_Config2__CustomFieldNames2__c = 'APTS_Bound_To_HCM__c,Growth_Year__c,Apttus_Config2__Description__c,APTS_Product_Configuration_Type__c,APTS_Associated_Worker_Types__c,APTS_Configuration_Type__c,Growth__c,APTS_Product_Family__c,System_Calculated_Hours__c,Option_Code__c,Product_Code__c';
        clicf7.Apttus_Config2__CustomFieldNames3__c = 'APTS_Subscriptions_Product_Category__c,APTS_Parent_Growth_Bundle_Unique_Key__c,Quote_Term__c,SKU__c,Total_Hours_Override__c,Micro_Product_SKUs__c,Workday_Services_LDP__c,Apttus_Config2__PriceListItemId__r.APTS_Quantity_from_FSE__c';
        clicf7.Apttus_Config2__CustomFieldNames4__c = 'Effective_End_Date__c,Effective_Start_Date__c,Paid_First_Year__c,APTS_Sibling_Payroll_Flag__c,Sales_ACV__c,Pricing_Date_Override__c,Price_Date_Active_Override__c,FSE__c,Cash_Upfront__c,APTS_Booking_Amount_List__c,Assessment_Effort_Level__c';
        clicf7.Apttus_Config2__CustomFieldNames5__c = 'APTS_TCV__c,Start_Date_Override__c,End_Date_Override__c,APTS_PEPY__c,Opportunity_Type__c,APTS_Is_PEPY_Overridden__c,PEPY_Override__c,APTS_Tools_Fee__c,APTS_Pre_GA_Credit__c,APTS_Incentive_Credit__c,ACV__c,ACV_List__c,APTS_SKU_Pricing_Model__c';
        clicfs.add(clicf7);
        Apttus_Config2__ConfigLineItemCustomFields__c clicf8 = new Apttus_Config2__ConfigLineItemCustomFields__c();
        clicf8.Name = 'S8';
        clicf8.Apttus_Config2__CustomFieldNames__c = 'APTS_Product_Config_End_Date__c,APTS_ContrDiscPercFormula__c,APTS_Expansion_Quantity_PRCT__c,APTS_ContrDiscPerc__c,APTS_Expansion_Type__c';
        clicf8.Apttus_Config2__CustomFieldNames2__c = 'APTS_ExpWorkerReportId__c,APTS_Prior_Expansion_Quantity__c,APTS_IsUpgraded__c';
        clicf8.Apttus_Config2__CustomFieldNames3__c = 'APTS_Uplift_Rate__c';

        
        clicfs.add(clicf8);

        Insert clicfs;
    }

    public static APTS_Worker_Report__c createWorkerModelInitialData() {
        
        
           Data_Management__c dm = Data_Management__c.getInstance(UserInfo.getOrganizationId());
        dm.SetupOwnerId=UserInfo.getOrganizationId();
        dm.Restrict_Account_Workflow_PB__c=true;
        dm.Restrict_Opportunity_Workflow_PB__c=true;
        dm.Restrict_Contact_Workflow_PB__c=true;
        dm.Restrict_Case_Workflow_PB__c=true;
        dm.Restrict_Agreement_Workflow_PB__c=true;
        dm.Restrict_Quote_Workflow_PB__c=true;
        dm.Restrict_Task_Workflow_PB__c=true;
        dm.Restrict_User_Workflow_PB__c=true;
        dm.PPLA_Check__c = true;
        upsert dm;

        Account acc = createAccount();
        acc.BillingCountry='Austria';
        insert acc;
        Opportunity oppty = createOpportunity('WD Oppty', acc.Id);
        insert oppty;
        Product2 pr2 = createProduct('Product A', 'Product A');
        insert pr2;

        APTS_WD_Worker_Model__c workerModel = createWorkerModel();
        insert workerModel;

        APTS_WD_Worker_Model_Category__c workerModelCat = createWorkerModelCategory(workerModel.id);
        insert workerModelCat;

        APTS_WD_FSE_CALC_EXCL__c fseCalcExcl = createFSECalculationExclusion(workerModelCat.id, pr2.id);
        insert fseCalcExcl;

        APTS_WD_WM_Product__c workerModelProduct = createWorkerModelProduct(workerModel.id, pr2.id);
        insert workerModelProduct;

        APTS_WD_Customer_Worker_Model__c customerWorkerModel = createCustomerWorkerModel(workerModel.id, acc.id);
        insert customerWorkerModel;

        APTS_WD_Customer_WMC__c customerSpecificCat = createCustomerSpecificCategory(workerModel.id, customerWorkerModel.id, workerModelCat.id);
        insert customerSpecificCat;

        APTS_Worker_Report__c workerReport = createWorkerReport(customerWorkerModel.id, acc.id);
        insert workerReport;

        APTS_WD_Worker_Report_Item__c workerReportItem = createWorkerReportItem(workerReport.id, customerSpecificCat.id, workerModelCat.id);
        insert workerReportItem;

        return workerReport;
    }


    public static APTS_WD_Worker_Model__c createWorkerModel(){
       
        return new APTS_WD_Worker_Model__c(
            Name = 'New FSE Model',
            APTS_Active__c = true,
            APTS_Description__c = 'Test Description',
            Type__c = 'Standard',
            Default__c = true
        );
    }

    public static APTS_WD_Worker_Model_Category__c createWorkerModelCategory(ID workerModelId){
       
        return new APTS_WD_Worker_Model_Category__c(
            APTS_Worker_Model__c = workerModelId,
            Name = 'Standard Full-Time',
            Sequence__c = 1,
            APTS_Weight__c = 100,
            APTS_Approval_Needed__c = false,
            Normalized_Category__c = 'Full-Time',
            Restricted__c = false
        );
    }

    public static APTS_WD_FSE_CALC_EXCL__c createFSECalculationExclusion(ID workerModelCatId, ID productId){
       
        return new APTS_WD_FSE_CALC_EXCL__c(
            APTS_WMC__c = workerModelCatId,
            APTS_WMPC__c = productId
        );
    }

    public static APTS_WD_WM_Product__c createWorkerModelProduct(ID workerModelId, ID productId){
       
        return new APTS_WD_WM_Product__c(
            APTS_Worker_Model__c = workerModelId,
            APTS_Product_Model__c = productId
        );
    }

    public static APTS_WD_Customer_Worker_Model__c createCustomerWorkerModel(ID workerModelId, ID accountId){
       
        return new APTS_WD_Customer_Worker_Model__c(
            APTS_Worker_Model__c = workerModelId,
            APTS_Account__c = accountId,
            APTS_Effective_Start_Date__c = System.today(),
            APTS_Effective_End_Date__c = System.today().addDays(30)
        );
    }

    public static APTS_WD_Customer_WMC__c createCustomerSpecificCategory(ID workerModelId, ID customerWorkerModelId, ID workerModelCatId){
       
        return new APTS_WD_Customer_WMC__c(
            APTS_Worker_Model__c = workerModelId,
            APTS_Customer_Worker_Model__c = customerWorkerModelId,
            APTS_Worker_Model_Category__c = workerModelCatId,
            APTS_Customer_Category__c = 'Banana Picker',
            APTS_Customer_Weight__c = 50,
            APTS_Approved_By__c = 'Unknown'

        );
    }

    public static APTS_Worker_Report__c createWorkerReport(ID customerWorkerModelId, ID accountId){
       
        return new APTS_Worker_Report__c(
            APTS_Report_Date__c = System.today(),
            APTS_Customer_Worker_Model__c = customerWorkerModelId,
            APTS_Status__c = 'Created',
            APTS_Submitted_Date__c = System.today(),
            APTS_Type__c = 'Master',
            APTS_Account__c = accountId
        );
    }    

    public static APTS_WD_QWR__c createQuoteWorkerReport(ID proposalId, ID workerReportId){
       
        return new APTS_WD_QWR__c(
            APTS_Quote_Proposal__c = proposalId,
            APTS_Worker_Report__c = workerReportId
        );
    }    

    public static APTS_WD_Worker_Report_Item__c createWorkerReportItem(ID workerReport, ID customerSpecificCat, ID workerModelCat){
       
        return new APTS_WD_Worker_Report_Item__c(
            APTS_Worker_Report__c = workerReport,
            APTS_Worker_Model_Category__c = workerModelCat,
            APTS_Customer_Specific_Category__c = customerSpecificCat
        );
    }

    public static APTS_WD_WR_ETOTAL__c createExceptionTotal(ID workerReportId, ID productId){
       
        return new APTS_WD_WR_ETOTAL__c(
            APTS_Product__c = productId,
            APTS_FSE_Total__c = 569,
            APTS_Worker_Report__c = workerReportId
        );
    }
   
    public static APTS_Number_Of_Employees__c createNumberOfEmployees(String name, Decimal noEmpl){
       
        return new APTS_Number_Of_Employees__c(
               Name = name,
               APTS_Number_Of_Employees__c = noEmpl
        );
    }

    public static void createAndInsertNumberOfEmployees(){
       
        APTS_Number_Of_Employees__c noEmpl = new APTS_Number_Of_Employees__c();
        noEmpl.Name = '400';
        noEmpl.APTS_Number_Of_Employees__c = 400;
        insert noEmpl;
    }

    public static APTS_Implementation_Type_Exception__c createLEImplTypeExc(String name, String value){
       
        return new APTS_Implementation_Type_Exception__c(
               Name = name,
               APTS_Field_API__c = name,
               APTS_Value__c = value,
               APTS_SKU_Pricing_Model__c = 'Large Enterprise'
        );
    }

    public static APTS_Implementation_Type_Profile__c createImplTypeProfile(String name, String profileName){
       
        return new APTS_Implementation_Type_Profile__c(
               Name = name,
               APTS_Profile_Name__c = profileName
        );
    }

    public static List<APTS_Pricing_Logic__c> createPricingLogics(){

        List<APTS_Pricing_Logic__c> pls = new List<APTS_Pricing_Logic__c>();
        APTS_Pricing_Logic__c pl1 = new APTS_Pricing_Logic__c();
        pl1.Name = 'Simple Net ACV';
        pl1.APTS_Active__c = true;
        pl1.APTS_Aggregate_Field__c = null;
        pl1.APTS_Filter_Criteria__c = 'Apttus_Config2__LineType__c = \'Option\'';
        pl1.APTS_Start_Date__c = System.today().addDays(-30);
        pl1.APTS_End_Date__c = System.today().addDays(90);
        pl1.APTS_Expression__c = 'Apttus_Config2__BasePrice__c * Apttus_Config2__Quantity__c * (1 + Apttus_Config2__NetAdjustmentPercent__c)';
        pl1.APTS_Fields__c = 'Apttus_Config2__BasePrice__c,Apttus_Config2__Quantity__c,Apttus_Config2__NetAdjustmentPercent__c,Apttus_Config2__LineType__c,Apttus_Config2__IsPrimaryLine__c';
        pl1.APTS_Query_Fields_Object__c = 'Apttus_Config2__LineItem__c';
        pl1.APTS_Primary_Field_Criteria__c = 'Apttus_Config2__IsPrimaryLine__c = true';
        pl1.APTS_Sequence__c = 1;
        pl1.APTS_Target_Field__c = 'APTS_Simple_Net_ACV__c';
        pl1.APTS_Target_Object__c = 'Apttus_Config2__LineItem__c';
        pl1.APTS_Type__c = 'Simple';
        pl1.APTS_Pricing_Calculation_Type__c='Regular';
        pls.add(pl1);

        APTS_Pricing_Logic__c pl2 = new APTS_Pricing_Logic__c();
        pl2.Name = 'Total Contract Value';
        pl2.APTS_Active__c = true;
        pl2.APTS_Aggregate_Field__c = null;
        pl2.APTS_Filter_Criteria__c = 'Apttus_Config2__LineType__c = \'Option\'';
        pl2.APTS_Start_Date__c = System.today().addDays(-30);
        pl2.APTS_End_Date__c = System.today().addDays(90);
        pl2.APTS_Expression__c = 'SUM(Apttus_Config2__NetPrice__c)';
        pl2.APTS_Fields__c = 'Apttus_Config2__NetPrice__c,Apttus_Config2__LineType__c,Apttus_Config2__IsPrimaryLine__c';
        pl2.APTS_Query_Fields_Object__c = 'Apttus_Config2__LineItem__c';
        pl2.APTS_Primary_Field_Criteria__c = 'Apttus_Config2__IsPrimaryLine__c = true';
        pl2.APTS_Sequence__c = 3;
        pl2.APTS_Target_Field__c = 'TCV__c';
        pl2.APTS_Target_Object__c = 'Apttus_Proposal__Proposal__c';
        pl2.APTS_Type__c = 'Aggregate';
        pl2.APTS_Pricing_Calculation_Type__c='Regular';
        pls.add(pl2);

        APTS_Pricing_Logic__c pl3 = new APTS_Pricing_Logic__c();
        pl3.Name = 'SKU Prorated Quantity';
        pl3.APTS_Active__c = true;
        pl3.APTS_Aggregate_Field__c = 'Apttus_Config2__PrimaryLineNumber__c';
        pl3.APTS_Filter_Criteria__c = null;
        pl3.APTS_Start_Date__c = System.today().addDays(-30);
        pl3.APTS_End_Date__c = System.today().addDays(90);
        pl3.APTS_Expression__c = 'SUM(Apttus_Config2__Quantity__c * Apttus_Config2__SellingTerm__c)';
        pl3.APTS_Fields__c = 'Apttus_Config2__Quantity__c,Apttus_Config2__SellingTerm__c,Apttus_Config2__IsPrimaryLine__c';
        pl3.APTS_Query_Fields_Object__c = 'Apttus_Config2__LineItem__c';
        pl3.APTS_Primary_Field_Criteria__c = 'Apttus_Config2__IsPrimaryLine__c = true';
        pl3.APTS_Sequence__c = 2;
        pl3.APTS_Target_Field__c = 'AG_SKU_Quantity__c';
        pl3.APTS_Target_Object__c = 'Apttus_Config2__LineItem__c';
        pl3.APTS_Type__c = 'Aggregate';
        pl3.APTS_Pricing_Calculation_Type__c='Regular';
        pls.add(pl3);

        APTS_Pricing_Logic__c pl4 = new APTS_Pricing_Logic__c();
        pl4.Name = 'SKU Start Date';
        pl4.APTS_Active__c = true;
        pl4.APTS_Aggregate_Field__c = 'Apttus_Config2__PrimaryLineNumber__c';
        pl4.APTS_Filter_Criteria__c = 'Apttus_Config2__LineType__c = \'Option\' && Apttus_Config2__StartDate__c != null';
        pl4.APTS_Start_Date__c = System.today().addDays(-30);
        pl4.APTS_End_Date__c = System.today().addDays(90);
        pl4.APTS_Expression__c = 'MINDATE(Apttus_Config2__StartDate__c)';
        pl4.APTS_Fields__c = 'Apttus_Config2__StartDate__c, Apttus_Config2__LineType__c, Apttus_Config2__IsPrimaryLine__c';
        pl4.APTS_Query_Fields_Object__c = 'Apttus_Config2__LineItem__c';
        pl4.APTS_Primary_Field_Criteria__c = 'Apttus_Config2__IsPrimaryLine__c = true';
        pl4.APTS_Sequence__c = 102;
        pl4.APTS_Target_Field__c = 'APTS_SKU_Start_Date__c';
        pl4.APTS_Target_Field_Type__c = 'DATE';
        pl4.APTS_Target_Object__c = 'Apttus_Config2__LineItem__c';
        pl4.APTS_Type__c = 'Aggregate';
        pl4.APTS_Pricing_Calculation_Type__c='Regular';
        pls.add(pl4);

        APTS_Pricing_Logic__c pl6 = new APTS_Pricing_Logic__c();
        pl6.Name = 'Ramp Line Count';
        pl6.APTS_Active__c = true;
        pl6.APTS_Aggregate_Field__c = 'Apttus_Config2__PrimaryLineNumber__c';
        pl6.APTS_Filter_Criteria__c = 'Apttus_Config2__LineType__c = \'Option\'';
        pl6.APTS_Start_Date__c = System.today().addDays(-30);
        pl6.APTS_End_Date__c = System.today().addDays(90);
        pl6.APTS_Expression__c = 'COUNT(1)';
        pl6.APTS_Fields__c = 'Apttus_Config2__LineType__c';
        pl6.APTS_Query_Fields_Object__c = 'Apttus_Config2__LineItem__c';
        pl6.APTS_Primary_Field_Criteria__c = 'Apttus_Config2__LineType__c = \'Option\'';
        pl6.APTS_Sequence__c = 36;
        pl6.APTS_Target_Field__c = 'AG_Ramp_Line_Count__c';
        pl6.APTS_Target_Object__c = 'Apttus_Config2__LineItem__c';
        pl6.APTS_Type__c = 'Aggregate';
        pl6.APTS_Pricing_Calculation_Type__c='Regular';
        pls.add(pl6);

        APTS_Pricing_Logic__c pl7 = new APTS_Pricing_Logic__c();
        pl7.Name = 'Simple Net ACV - Reset';
        pl7.APTS_Active__c = true;
        pl7.APTS_Aggregate_Field__c = null;
        pl7.APTS_Filter_Criteria__c = 'Apttus_Config2__LineType__c = \'Option\'';
        pl7.APTS_Start_Date__c = System.today().addDays(-30);
        pl7.APTS_End_Date__c = System.today().addDays(90);
        pl7.APTS_Expression__c = null;
        pl7.APTS_Fields__c = 'Apttus_Config2__LineType__c';
        pl7.APTS_Query_Fields_Object__c = 'Apttus_Config2__LineItem__c';
        pl7.APTS_Primary_Field_Criteria__c = null;
        pl7.APTS_Sequence__c = -1;
        pl7.APTS_Target_Field__c = 'APTS_Simple_Net_ACV__c';
        pl7.APTS_Target_Object__c = 'Apttus_Config2__LineItem__c';
        pl7.APTS_Type__c = 'Reset';
        pl7.APTS_Target_Field_Type__c = 'NUMBER';
        pl7.APTS_Pricing_Calculation_Type__c='Regular';
        pls.add(pl7);

        APTS_Pricing_Logic__c pl8 = new APTS_Pricing_Logic__c();
        pl8.Name = 'SKU End Date';
        pl8.APTS_Active__c = true;
        pl8.APTS_Aggregate_Field__c = 'Apttus_Config2__PrimaryLineNumber__c';
        pl8.APTS_Filter_Criteria__c = 'Apttus_Config2__LineType__c = \'Option\' && Apttus_Config2__EndDate__c != null';
        pl8.APTS_Start_Date__c = System.today().addDays(-30);
        pl8.APTS_End_Date__c = System.today().addDays(90);
        pl8.APTS_Expression__c = 'MAXDATE(Apttus_Config2__EndDate__c)';
        pl8.APTS_Fields__c = 'Apttus_Config2__EndDate__c, Apttus_Config2__IsPrimaryLine__c, Apttus_Config2__LineType__c';
        pl8.APTS_Query_Fields_Object__c = 'Apttus_Config2__LineItem__c';
        pl8.APTS_Primary_Field_Criteria__c = null;
        pl8.APTS_Sequence__c = 172;
        pl8.APTS_Target_Field__c = 'APTS_SKU_End_Date__c';
        pl8.APTS_Target_Field_Type__c = 'DATE';
        pl8.APTS_Target_Object__c = 'Apttus_Config2__LineItem__c';
        pl8.APTS_Type__c = 'Aggregate';
        pl8.APTS_Pricing_Calculation_Type__c='Regular';
        pls.add(pl8);

        APTS_Pricing_Logic__c pl9 = new APTS_Pricing_Logic__c();
        pl9.Name = 'List Price';
        pl9.APTS_Active__c = true;
        pl9.APTS_Aggregate_Field__c = null;
        pl9.APTS_Filter_Criteria__c = null;
        pl9.APTS_Start_Date__c = System.today().addDays(-30);
        pl9.APTS_End_Date__c = System.today().addDays(90);
        pl9.APTS_Expression__c = 'Round(MAX(Apttus_Config2__BasePrice__c,APTS_Floor_List__c) * IF(APTS_LimitedUse__c > 0, APTS_LimitedUse__c/100, 1),2)';
        pl9.APTS_Fields__c = 'Apttus_Config2__BasePrice__c,APTS_Floor_List__c, APTS_LimitedUse__c';
        pl9.APTS_Query_Fields_Object__c = 'Apttus_Config2__LineItem__c';
        pl9.APTS_Primary_Field_Criteria__c = null;
        pl9.APTS_Sequence__c = 115;
        pl9.APTS_Target_Field__c = 'Apttus_Config2__ListPrice__c';
        pl9.APTS_Target_Field_Type__c = 'NUMBER';
        pl9.APTS_Target_Object__c = 'Apttus_Config2__LineItem__c';
        pl9.APTS_Type__c = 'Simple';
        pl9.APTS_ADJUSTMENT_Mode_Method__c = 'beforePricingLineItem';
        pl9.APTS_Pricing_Calculation_Type__c='Regular';
        pls.add(pl9);

        APTS_Pricing_Logic__c pl10 = new APTS_Pricing_Logic__c();
        pl10.Name = 'Headcount Reduction Line Count';
        pl10.APTS_Active__c = true;
        pl10.APTS_Aggregate_Field__c = 'Apttus_Config2__LineNumber__c';
        pl10.APTS_Filter_Criteria__c = 'Apttus_Config2__LineType__c = \'Option\'';
        pl10.APTS_Start_Date__c = System.today().addDays(-30);
        pl10.APTS_End_Date__c = System.today().addDays(90);
        pl10.APTS_Expression__c = 'COUNT(1)';
        pl10.APTS_Fields__c = 'Apttus_Config2__LineType__c';
        pl10.APTS_Query_Fields_Object__c = 'Apttus_Config2__LineItem__c';
        pl10.APTS_Primary_Field_Criteria__c = null;
        pl10.APTS_Sequence__c = 162;
        pl10.APTS_Target_Field__c = 'APTS_Headcount_Reduction_Line_Count__c';
        pl10.APTS_Target_Object__c = 'Apttus_Config2__LineItem__c';
        pl10.APTS_Type__c = 'Aggregate';
        pl10.APTS_Target_Field_Type__c = 'NUMBER';
        pl10.APTS_ADJUSTMENT_Mode_Method__c = 'beforePricing';
        pl10.APTS_ExprFieldType__c = 'Decimal';
        pl10.APTS_Pricing_Calculation_Type__c='Regular';
        pls.add(pl10);

        return pls;
    }

    public static APTS_WD_CPI__c createCPI(){
        return new APTS_WD_CPI__c(
               APTS_CPI_Rate__c = 10.00,
               APTS_Effective_Start_Date__c = System.now(),
               APTS_Effective_End_Date__c = System.now().addMonths(12)
        );
    }

    public static void createCustomSettings(){
        createAndInsertWRCustomSettings();
        APTS_Number_Of_Employees__c numberOfEmployees = createNumberOfEmployees('400', 400);
        insert numberOfEmployees;
    }

    public static void createAndInsertWRCustomSettings(){
        createAndInsertCustomPageCustomSettings();
        createAndInsertRCAPCustomSettings();
        createAndInsertWRCFCustomSettings();
    }

    public static void createAndInsertCustomPageCustomSettings(){
        List<APTS_Custom_Pages_Settings__c> cps = new List<APTS_Custom_Pages_Settings__c>();
        cps.add(new APTS_Custom_Pages_Settings__c(Name='QER Model Name', APTS_Column_Display_Order__c=1, APTS_Display_Field_API_Name__c='APTS_Worker_Model_Name__c', APTS_Page_Name__c='ExistingReports', APTS_Label__c='Model'));
        cps.add(new APTS_Custom_Pages_Settings__c(Name='QER Report Date', APTS_Column_Display_Order__c=2, APTS_Display_Field_API_Name__c='APTS_Report_Date__c', APTS_Page_Name__c='ExistingReports', APTS_Label__c='Report Date'));
        cps.add(new APTS_Custom_Pages_Settings__c(Name='WR Quantity', APTS_Column_Display_Order__c=2, APTS_Display_Field_API_Name__c='Apttus_Config2__Quantity__c', APTS_Page_Name__c='WorkerReport', APTS_Label__c='Quantity'));
        cps.add(new APTS_Custom_Pages_Settings__c(Name='WR Start Date', APTS_Column_Display_Order__c=3, APTS_Display_Field_API_Name__c='Apttus_Config2__StartDate__c', APTS_Page_Name__c='WorkerReport', APTS_Label__c='Start Date'));
        insert cps;
    }

    public static void createAndInsertRCAPCustomSettings(){
        List<APTS_WorkerReportManagmentProfiles__c> css = new List<APTS_WorkerReportManagmentProfiles__c>();
        css.add(new APTS_WorkerReportManagmentProfiles__c(Name='1', APTS_AccessObject__c=APTS_WorkerReportUtil.PRF_ACCESS_CAPFER, APTS_Profile_Name__c='System Administrator'));
        css.add(new APTS_WorkerReportManagmentProfiles__c(Name='2', APTS_AccessObject__c=APTS_WorkerReportUtil.PRF_ACCESS_CAPFER,  APTS_Profile_Name__c='Sales/Ops Admin'));
        css.add(new APTS_WorkerReportManagmentProfiles__c(Name='3', APTS_AccessObject__c=APTS_WorkerReportUtil.PRF_ACCESS_CANSC,  APTS_Profile_Name__c='System Administrator'));
        css.add(new APTS_WorkerReportManagmentProfiles__c(Name='4', APTS_AccessObject__c=APTS_WorkerReportUtil.PRF_ACCESS_CANSC,   APTS_Profile_Name__c='Sales/Ops Admin'));
        insert css;
    }

    public static void createAndInsertWRCFCustomSettings(){
        List<APTS_WorkerReportCloneFields__c> wrcfs = new List<APTS_WorkerReportCloneFields__c>();
        wrcfs.add(new APTS_WorkerReportCloneFields__c(Name='1', APTS_Clone_API_Name__c='WorkerReport', APTS_Field_API_Name__c='APTS_Account__c'));
        wrcfs.add(new APTS_WorkerReportCloneFields__c(Name='2', APTS_Clone_API_Name__c='WorkerReport', APTS_Field_API_Name__c='APTS_Customer_Worker_Model__c'));
        wrcfs.add(new APTS_WorkerReportCloneFields__c(Name='3', APTS_Clone_API_Name__c='WorkerReportItem', APTS_Field_API_Name__c='APTS_Customer_Specific_Category__c'));
        wrcfs.add(new APTS_WorkerReportCloneFields__c(Name='4', APTS_Clone_API_Name__c='WorkerReportItem', APTS_Field_API_Name__c='APTS_FSE__c'));
        wrcfs.add(new APTS_WorkerReportCloneFields__c(Name='5', APTS_Clone_API_Name__c='WorkerReportItem', APTS_Field_API_Name__c='APTS_Previous_Quantity__c'));
        wrcfs.add(new APTS_WorkerReportCloneFields__c(Name='6', APTS_Clone_API_Name__c='WorkerReportItem', APTS_Field_API_Name__c='APTS_Quantity__c'));
        wrcfs.add(new APTS_WorkerReportCloneFields__c(Name='7', APTS_Clone_API_Name__c='WorkerReportItem', APTS_Field_API_Name__c='APTS_Weight__c'));
        wrcfs.add(new APTS_WorkerReportCloneFields__c(Name='8', APTS_Clone_API_Name__c='WorkerReportItem', APTS_Field_API_Name__c='APTS_Worker_Model_Category__c'));
        wrcfs.add(new APTS_WorkerReportCloneFields__c(Name='9', APTS_Clone_API_Name__c='WorkerReportItem', APTS_Field_API_Name__c='APTS_Worker_Report__c'));
        wrcfs.add(new APTS_WorkerReportCloneFields__c(Name='10', APTS_Clone_API_Name__c='WorkerReport', APTS_Field_API_Name__c='APTS_Report_Date__c'));
        wrcfs.add(new APTS_WorkerReportCloneFields__c(Name='11', APTS_Clone_API_Name__c='WorkerReport', APTS_Field_API_Name__c='APTS_Status__c'));
        wrcfs.add(new APTS_WorkerReportCloneFields__c(Name='12', APTS_Clone_API_Name__c='WorkerReport', APTS_Field_API_Name__c='APTS_Submitted_Date__c'));
        wrcfs.add(new APTS_WorkerReportCloneFields__c(Name='13', APTS_Clone_API_Name__c='WorkerReport', APTS_Field_API_Name__c='APTS_Type__c'));
        insert wrcfs;
    }

    public static void createAndInsertOverrideBaselinePageCustomSettings(){
        List<APTS_Custom_Pages_Settings__c> cps = new List<APTS_Custom_Pages_Settings__c>();
        cps.add(new APTS_Custom_Pages_Settings__c(Name='Override - Product Name', APTS_Column_Display_Order__c=1, APTS_Display_Field_API_Name__c='Apttus_Config2__Description__c', APTS_Page_Name__c='OverrideACVPEPY', APTS_Label__c='Product Name'));
        cps.add(new APTS_Custom_Pages_Settings__c(Name='Override - Quantity', APTS_Column_Display_Order__c=2, APTS_Display_Field_API_Name__c='Apttus_Config2__Quantity__c', APTS_Page_Name__c='OverrideACVPEPY', APTS_Label__c='Quantity'));
        cps.add(new APTS_Custom_Pages_Settings__c(Name='Override - Start Date', APTS_Column_Display_Order__c=3, APTS_Display_Field_API_Name__c='Apttus_Config2__StartDate__c', APTS_Page_Name__c='OverrideACVPEPY', APTS_Label__c='Start Date'));
        cps.add(new APTS_Custom_Pages_Settings__c(Name='Override - End Date', APTS_Column_Display_Order__c=4, APTS_Display_Field_API_Name__c='Apttus_Config2__EndDate__c', APTS_Page_Name__c='OverrideACVPEPY', APTS_Label__c='End Date'));
        insert cps;
    }

    public static Apttus_Proposal__Proposal_Line_Item__c getProposalLineItem(ID proposalId,ID configId, Id product2Id) {
        Apttus_Proposal__Proposal_Line_Item__c lineItemSO = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId, Apttus_QPConfig__ConfigurationId__c = configId);
        lineItemSO.Apttus_QPConfig__PrimaryLineNumber__c = 1;
        lineItemSO.Apttus_QPConfig__LineNumber__c = 1;
        lineItemSO.Apttus_QPConfig__IsPrimaryLine__c = true;   
        lineItemSO.Apttus_QPConfig__LineType__c = 'Product/Service';
        lineItemSO.Apttus_Proposal__Product__c = product2Id;

        return lineItemSO;  
    }
 }