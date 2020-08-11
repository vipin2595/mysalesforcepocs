@IsTest
public class RenewalSummaryCmpControllerTest {
	@IsTest
    static void RenewalSummaryTest() {
        
        Test.startTest();
            APTS_TestSetup.createAndInsertCustomSettings(); 
            APTS_TestSetup.createInitialData();

            Product2 pr2 = APTS_TestSetup.createProduct('Product 2', 'HCM');
            pr2.bound_to_HCM__c = 'Full';
            pr2.Apttus_Config2__ConfigurationType__c ='Option';
            Product2 pr3 = APTS_TestSetup.createProduct('Product 3', 'Product 3');
            pr3.bound_to_HCM__c = 'Partial';
            Product2 pr4 = APTS_TestSetup.createProduct('Planning', 'PLN');
            pr4.bound_to_HCM__c = 'Full';
            pr4.Apttus_Config2__ConfigurationType__c ='Option';
            Insert new List<Product2>{
                pr2,
                pr3, 
                pr4
            }; 

            insert new Data_Migration__c (
                Name='Apttus__APTS_Agreement__c',
                Exclude_Triggers__c = false
            ); 

            Opportunity oppty = [Select Id From Opportunity Limit 1]; 
            Account acc = [Select Id From Account Limit 1];
            
            APTS_WD_Worker_Model__c workerModel = APTS_TestSetup.createWorkerModel();
            insert workerModel;

            APTS_WD_Worker_Model_Category__c workerModelCat = APTS_TestSetup.createWorkerModelCategory(workerModel.id);
            insert workerModelCat;

            APTS_WD_FSE_CALC_EXCL__c fseCalcExcl = APTS_TestSetup.createFSECalculationExclusion(workerModelCat.id, pr2.id);
            insert fseCalcExcl;

            APTS_WD_WM_Product__c workerModelProduct = APTS_TestSetup.createWorkerModelProduct(workerModel.id, pr2.id);
            insert workerModelProduct;

            APTS_WD_Customer_Worker_Model__c customerWorkerModel = APTS_TestSetup.createCustomerWorkerModel(workerModel.id, acc.id);
            insert customerWorkerModel;

            APTS_WD_Customer_WMC__c customerSpecificCat = APTS_TestSetup.createCustomerSpecificCategory(workerModel.id, customerWorkerModel.id, workerModelCat.id);
            insert customerSpecificCat;

            APTS_Worker_Report__c workerReport = APTS_TestSetup.createWorkerReport(customerWorkerModel.id, acc.id);
            insert workerReport;

            APTS_WD_Worker_Report_Item__c workerReportItem = APTS_TestSetup.createWorkerReportItem(workerReport.id, customerSpecificCat.id, workerModelCat.id);
            insert workerReportItem;
            
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
            List<Product2> products = [
                SELECT 
                    Id 
                FROM Product2
            ];
            Apttus_Proposal__Proposal__c proposal = APTS_TestSetup.createProposal(oppty.id,priceList.id);
                proposal.APTS_R_Baseline_Reduction_FSE__c = 100;
                proposal.Contractual_Baseline__c = 200;
                proposal.APTS_Expansion_Baseline_ACV__c = 210;
                proposal.APTS_Target_Innovation_Index__c = 210;
                proposal.APTS_Volume_Discount_ACV__c = 340;
                proposal.Contractual_Baseline__c = 33;
                proposal.APTS_R_Baseline_Reduction_FSE__c = 44;
                proposal.APTS_R_Baseline_Reduction_SKU__c = 55; 
                proposal.APTS_R_Baseline_Other_Adjustment__c = 76;
                proposal.APTS_Expansion_Baseline_ACV__c = 78;
                proposal.APTS_Volume_Discount_ACV__c = 89;
            insert proposal;

            Apttus_Config2__ProductConfiguration__c productConfig = APTS_TestSetup.createCart(proposal.id,priceList.id); 
            insert productConfig;
            
            Apttus_Config2__LineItem__c  lineitemcreation =APTS_TestSetup.createLineItem(priceList.id,productConfig.id,products[0].id,pli.id);
            insert lineitemcreation;
            
            Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = APTS_TestSetup.getProposalLineItem(proposal.Id, productConfig.Id, products[1].id);
                proposalLineItem.APTS_Baseline_PEPY__c = 34;
                proposalLineItem.APTS_Final_Base_PEPY__c = 22;
                proposalLineItem.APTS_Price_Net_Uplift__c = 11;
                proposalLineItem.APTS_Baseline_PEPY__c = 56;
                proposalLineItem.APTS_Baseline_ACV__c = 239;
        		proposalLineItem.Apttus_QPConfig__PriceUom__c = ProposalLineItemTriggerHelper.PRICE_UOM_FSE;
            Apttus_Proposal__Proposal_Line_Item__c proposalLineItem2 = APTS_TestSetup.getProposalLineItem(proposal.Id, productConfig.Id, products[0].id);
                proposalLineItem2.Apttus_QPConfig__LineType__c = proposalLineItemTriggerHelper.OPTION;
                proposalLineItem2.Apttus_QPConfig__IsPrimaryRampLine__c = RenewalSummaryCmpController.BOOLEAN_TRUE;
                proposalLineItem2.APTS_Baseline_PEPY__c = 34;
                proposalLineItem2.APTS_Final_Base_PEPY__c = 22;
                proposalLineItem2.APTS_Price_Net_Uplift__c = 11;
                proposalLineItem2.APTS_Baseline_PEPY__c = 56;
                proposalLineItem2.APTS_Baseline_ACV__c = 239;
        		proposalLineItem.Apttus_QPConfig__PriceUom__c = ProposalLineItemTriggerHelper.PRICE_UOM_FSE;
            insert new List<Apttus_Proposal__Proposal_Line_Item__c>{
                proposalLineItem, 
                proposalLineItem2
            }; 

            RenewalSummaryCmpController.propId = proposal.Id;
            Map<Id, Apttus_Proposal__Proposal__c> getProposal = RenewalSummaryCmpController.getProposal;
            List<RenewalSummaryCmpController.proposalPayload> renwalCmpProposalPayload = new RenewalSummaryCmpController().proposalpayLd;
        Test.stopTest();
        
        system.assertEquals(true, !renwalCmpProposalPayload.isEmpty(), 'Proposal and proposal lineitem payload should have been created');
    }
    
    @IsTest
    static void RenewalSummaryNegativeTest() {
        
        Test.startTest();
            APTS_TestSetup.createAndInsertCustomSettings(); 
            APTS_TestSetup.createInitialData();

            Product2 pr2 = APTS_TestSetup.createProduct('Product 2', 'TT');
            pr2.bound_to_HCM__c = 'Full';
            pr2.Apttus_Config2__ConfigurationType__c ='Option';
            Product2 pr3 = APTS_TestSetup.createProduct('Product 3', 'Product 3');
            pr3.bound_to_HCM__c = 'Partial';
            Product2 pr4 = APTS_TestSetup.createProduct('Planning', 'PLN');
            pr4.bound_to_HCM__c = 'Full';
            pr4.Apttus_Config2__ConfigurationType__c ='Option';
            Insert new List<Product2>{
                pr2,
                pr3, 
                pr4
            }; 

            insert new Data_Migration__c (
                Name='Apttus__APTS_Agreement__c',
                Exclude_Triggers__c = false
            ); 

            Opportunity oppty = [Select Id From Opportunity Limit 1]; 
            Account acc = [Select Id From Account Limit 1];
            
            APTS_WD_Worker_Model__c workerModel = APTS_TestSetup.createWorkerModel();
            insert workerModel;

            APTS_WD_Worker_Model_Category__c workerModelCat = APTS_TestSetup.createWorkerModelCategory(workerModel.id);
            insert workerModelCat;

            APTS_WD_FSE_CALC_EXCL__c fseCalcExcl = APTS_TestSetup.createFSECalculationExclusion(workerModelCat.id, pr2.id);
            insert fseCalcExcl;

            APTS_WD_WM_Product__c workerModelProduct = APTS_TestSetup.createWorkerModelProduct(workerModel.id, pr2.id);
            insert workerModelProduct;

            APTS_WD_Customer_Worker_Model__c customerWorkerModel = APTS_TestSetup.createCustomerWorkerModel(workerModel.id, acc.id);
            insert customerWorkerModel;

            APTS_WD_Customer_WMC__c customerSpecificCat = APTS_TestSetup.createCustomerSpecificCategory(workerModel.id, customerWorkerModel.id, workerModelCat.id);
            insert customerSpecificCat;

            APTS_Worker_Report__c workerReport = APTS_TestSetup.createWorkerReport(customerWorkerModel.id, acc.id);
            insert workerReport;

            APTS_WD_Worker_Report_Item__c workerReportItem = APTS_TestSetup.createWorkerReportItem(workerReport.id, customerSpecificCat.id, workerModelCat.id);
            insert workerReportItem;
            
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
            List<Product2> products = [
                SELECT 
                    Id 
                FROM Product2
            ];
            Apttus_Proposal__Proposal__c proposal = APTS_TestSetup.createProposal(oppty.id,priceList.id);
            insert proposal;

            Apttus_Config2__ProductConfiguration__c productConfig = APTS_TestSetup.createCart(proposal.id,priceList.id); 
            insert productConfig;
            
            Apttus_Config2__LineItem__c  lineitemcreation =APTS_TestSetup.createLineItem(priceList.id,productConfig.id,products[0].id,pli.id);
            insert lineitemcreation;
            
            Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = APTS_TestSetup.getProposalLineItem(proposal.Id, productConfig.Id, products[1].id);
                
            Apttus_Proposal__Proposal_Line_Item__c proposalLineItem2 = APTS_TestSetup.getProposalLineItem(proposal.Id, productConfig.Id, products[0].id);
                proposalLineItem2.Apttus_QPConfig__LineType__c = proposalLineItemTriggerHelper.OPTION;
        		proposalLineItem.Apttus_QPConfig__PriceUom__c = ProposalLineItemTriggerHelper.PRICE_UOM_FSE;
            insert new List<Apttus_Proposal__Proposal_Line_Item__c>{
                proposalLineItem, 
                proposalLineItem2
            }; 

            RenewalSummaryCmpController.propId = proposal.Id;
            Map<Id, Apttus_Proposal__Proposal__c> getProposal = RenewalSummaryCmpController.getProposal;
            List<RenewalSummaryCmpController.proposalPayload> renwalCmpProposalPayload = new RenewalSummaryCmpController().proposalpayLd;
        Test.stopTest();
        
        system.assertEquals(true, !renwalCmpProposalPayload.isEmpty(), 'Proposal and proposal lineitem payload should have been created');
    }

}