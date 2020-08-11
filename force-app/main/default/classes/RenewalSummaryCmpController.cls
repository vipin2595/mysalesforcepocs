/*------------------------------------------------------------------------------

========================================================================================================================================================================================================================
Purpose:                                                           
-------  
This class is an controller class for Email template Renewal Summary Component.                                                         
========================================================================================================================================================================================================================
History                                                           
-------                                                           
VERSION  AUTHOR                    DATE             STORY
1.0      Deepika Reddy Palwai     07/07/2020       GTMOM-2781
******************************************************************************************************************************************************************/
public class RenewalSummaryCmpController {

    public static String propId {get; set;}
    public static final String HCM_PRODUCT = 'HCM';
    public static final Boolean BOOLEAN_TRUE = true;
    public static final String NEW_STATUS = 'New';
    public static final Boolean BOOLEAN_FALSE = false;

    public List<proposalPayload> proposalpayLd { 
        get{
            if(proposalpayLd == null) {
                proposalpayLd = new List<proposalPayload>();
                proposalPayload prop = new proposalPayload();
                prop.proposal = getProposal.Values();
                prop.PliPayLoad = getProposalLineItem();
                proposalpayLd.add(prop); 
            }
            return proposalpayLd;
        } set; 
    }
    
    public static Map<Id, Apttus_Proposal__Proposal__c> getProposal {
        get{
            if(getProposal == null){
                getProposal = new Map<Id, Apttus_Proposal__Proposal__c>(
                    [
                        SELECT
                            CurrencyIsoCode, Contractual_Baseline__c, APTS_R_Baseline_Reduction_FSE__c,
                            APTS_R_Baseline_Reduction_SKU__c, APTS_R_Baseline_Other_Adjustment__c, APTS_Expansion_Baseline_ACV__c,
                            APTS_Volume_Discount_ACV__c, APTS_Adjusted_Baseline_ACV__c, APTS_Pre_Negotiated_Term__c,
                            CPI_For_Renewal_Uplift__c, APTS_R_Net_Baseline_CPI__c, APTS_Target_Innovation_Index__c,
                            APTS_R_Net_Baseline_II__c, ATPS_Renewal_Subscription_Target_ACV__c, APTS_Root_PN_II_Rate__c,
                            APTS_II_Rate__c, APTS_Net_Innovation_Index__c, APTS_Delta_Innovation_Index__c,
                            APTS_Discretionary_Discount_ACV__c, APTS_Renewal_Subscription_ACV__c, APTS_New_Subscription_Discount__c,
                            APTS_Add_On_New_Subscription_ACV__c, Baseline_Renewal_Rate__c, Total_Renewal_Rate_new__c, 
                            APTS_Renewal_Subscription_Discount__c, Renewal_Negotiation_Type__c, APTS_Uplift_Renewal_Target_ACV__c,
                            Uplift_Renewal_Subscription_ACV__c, APTS_Growth_Adjusted_PEPY__c, APTS_Target_Uplifted_PEPY__c
                        FROM Apttus_Proposal__Proposal__c 
                        WHERE Id = :propId 
                    ]
                );
            }
            return getProposal;
        } 
        set; 
    }
    
    /*******************************************************************
    Purpose: Construct data for Proposal line item payload                                                         
    Parameters: N/A
    Returns: proposalLineItemPayload
    Throws [Exceptions]: N/A                                                      
    ********************************************************************/ 
    public proposalLineItemPayload getProposalLineItem() {
        Decimal baselineFseReduction;
        Decimal baseLineFseExpanstion;
        Decimal baselineAcvBeforeUplift;
        Decimal targetRenewalAcvUplift;
        Decimal realizedRenewalAcvUplift;
        Decimal baselineFseAdjusted;
        Decimal baselineAcvPepy = 0; 
        Decimal realizedRenewalAcvUpliftPepy = 0;
        Decimal addOnNetAcvPepy = 0;
        Boolean hcmCheck = false;
        
        Apttus_Proposal__Proposal__c prop = getProposal.get(propId);
            for(Apttus_Proposal__Proposal_Line_Item__c pli : queryProposalLineItem(propId)) {
                if(pli.Apttus_QPConfig__LineType__c == ProposalLineItemTriggerHelper.PRODUCT_SERVICE) {
                    baselineFseReduction = nullCheck(
                                                new Set<Decimal>{
                                                    prop.APTS_Adjusted_Baseline_ACV__c, 
                                                    pli.APTS_Baseline_ACV__c
                                                }
                                            ) 
                                            ? 0 
                                            : (prop.APTS_R_Baseline_Reduction_FSE__c/prop.Contractual_Baseline__c)*100;
                    baseLineFseExpanstion = nullCheck(
                                                new Set<Decimal>{
                                                    prop.APTS_Expansion_Baseline_ACV__c, 
                                                    prop.Contractual_Baseline__c
                                                }
                                            ) 
                                            ? 0 
                                            : (prop.APTS_Expansion_Baseline_ACV__c/prop.Contractual_Baseline__c)*100;
                    baselineAcvBeforeUplift = nullCheck(
                                                new Set<Decimal>{
                                                    prop.APTS_Adjusted_Baseline_ACV__c, 
                                                    pli.APTS_Baseline_ACV__c
                                                }
                                            ) 
                                            ? 0 
                                            : (prop.APTS_Adjusted_Baseline_ACV__c/pli.APTS_Baseline_ACV__c)*100;
                    targetRenewalAcvUplift = nullCheck(
                                                new Set<Decimal>{
                                                    prop.APTS_Target_Innovation_Index__c
                                                }
                                            ) 
                                            ? 0 
                                            : prop.APTS_Target_Innovation_Index__c;
                    RealizedRenewalAcvUplift = nullCheck(
                                                    new Set<Decimal>{
                                                        pli.APTS_Price_Net_Uplift__c
                                                    }
                                                ) 
                                                ? 0 
                                                : pli.APTS_Price_Net_Uplift__c;
                    baselineFseAdjusted = nullCheck(
                                            new Set<Decimal>{
                                                    prop.Contractual_Baseline__c, 
                                                    prop.APTS_R_Baseline_Reduction_FSE__c, 
                                                    prop.APTS_Expansion_Baseline_ACV__c, 
                                                    prop.APTS_Volume_Discount_ACV__c
                                                }
                                            ) 
                                            ? 0 
                                            : prop.Contractual_Baseline__c 
                                                + prop.APTS_R_Baseline_Reduction_FSE__c
                                                + prop.APTS_Expansion_Baseline_ACV__c
                                                + prop.APTS_Volume_Discount_ACV__c;
                }
                if(pli.Apttus_QPConfig__LineType__c == ProposalLineItemTriggerHelper.OPTION) {
                    if(!hcmCheck && pli.Apttus_QPConfig__LineStatus__c == ProposalLineItemTriggerHelper.LINE_RENEWED) {
                        hcmCheck = isLineItemHasHcm(pli.Product_Code__c);
                        baselineAcvPepy = !nullCheck(
                                            new Set<Decimal>{
                                                pli.APTS_Baseline_PEPY__c
                                            }
                                        ) && !hcmCheck
                                        ? baselineAcvPepy 
                                        : pli.APTS_Baseline_PEPY__c;
                        realizedRenewalAcvUpliftPepy = !nullCheck(
                                                            new Set<Decimal>{
                                                                pli.APTS_Final_Base_PEPY__c
                                                            }
                                                        ) && !hcmCheck
                                                        ? realizedRenewalAcvUpliftPepy 
                                                        : pli.APTS_Final_Base_PEPY__c;
                    }
                    if(!hcmCheck && pli.Apttus_QPConfig__PriceUom__c == ProposalLineItemTriggerHelper.PRICE_UOM_FSE 
                        && pli.Apttus_QPConfig__LineStatus__c == ProposalLineItemTriggerHelper.LINE_RENEWED
                    ) 
                    {
                        if(baselineAcvPepy < pli.APTS_Baseline_PEPY__c) {
                            baselineAcvPepy = pli.APTS_Baseline_PEPY__c;
                            realizedRenewalAcvUpliftPepy = pli.APTS_Final_Base_PEPY__c;
                        }
                    }
                    
                    addOnNetAcvPepy += nullCheck(
                                            new Set<Decimal>{
                                                pli.APTS_Final_Base_PEPY__c
                                            }
                                        )
                                        ? 0
                                        : pli.Apttus_QPConfig__LineStatus__c ==  NEW_STATUS
                                        ? pli.APTS_Final_Base_PEPY__c
                                        : 0;
                }                                           
            }
            return new proposalLineItemPayload(
                baselineFseReduction,
                baseLineFseExpanstion,
                baselineAcvBeforeUplift,
                targetRenewalAcvUplift,
                realizedRenewalAcvUplift,
                baselineFseAdjusted,
                baselineAcvPepy,
                realizedRenewalAcvUpliftPepy,
                addOnNetAcvPepy
            );
    }

    /*******************************************************************
    Purpose: Verify if the given field is null.                                                     
    Parameters: set of field values
    Returns: Boolean
    Throws [Exceptions]: N/A                                                      
    ********************************************************************/ 
    public Boolean nullCheck(Set<Decimal> fieldValues){
        if(fieldValues.contains(null)){
            return BOOLEAN_TRUE;
        }
        return BOOLEAN_FALSE;
    }
    /*******************************************************************
    Purpose: Verify if the given options has HCM product.                                                      
    Parameters: Product Name
    Returns: Boolean
    Throws [Exceptions]: N/A                                                      
    ********************************************************************/ 
    public Boolean isLineItemHasHcm(String productName) {
        if(productName.contains(HCM_PRODUCT)) {
            return BOOLEAN_TRUE;
        }else{
            return BOOLEAN_FALSE;
        }
    }

    /*******************************************************************
    Purpose: Query propoosal line item                                                      
    Parameters: proposal Id
    Returns: List of Apttus_Proposal__Proposal_Line_Item__c
    Throws [Exceptions]: N/A                                                      
    ********************************************************************/ 
    private static List<Apttus_Proposal__Proposal_Line_Item__c> queryProposalLineItem(Id proposalId) {
        return[
            SELECT 
                Id, 
                Apttus_QPConfig__LineType__c, 
                APTS_Baseline_ACV__c,
                APTS_Baseline_PEPY__c,
                Apttus_QPConfig__IsPrimaryLine__c,
                Product_Code__c,
                AG_SKU_EY_Quantity__c,
                Apttus_QPConfig__IsPrimaryRampLine__c,
                Apttus_Proposal__Quantity__c,
                APTS_Final_Base_PEPY__c,
                APTS_Price_Net_Uplift__c,
                Apttus_QPConfig__LineStatus__c,
                Apttus_QPConfig__PriceUom__c
            FROM Apttus_Proposal__Proposal_Line_Item__c
            WHERE Apttus_Proposal__Proposal__c = :proposalId
            AND Apttus_QPConfig__IsPrimaryLine__c = :BOOLEAN_TRUE
        ];
    }
    
	/*******************************************************************
    Purpose: Construct Quote/Proposal and Proposal line item payload                                                         
    Parameters: N/A
    Returns: N/A
    Throws [Exceptions]: N/A                                                      
    ********************************************************************/ 
    public class proposalPayload {
        public Apttus_Proposal__Proposal__c proposal {get; set;}
        public proposalLineItemPayload PliPayLoad {get; set;}
        public proposalPayload(){}
    }
	
    /*******************************************************************
    Purpose: Construct Proposal line item payload                                                         
    Parameters: N/A
    Returns: N/A
    Throws [Exceptions]: N/A                                                      
    ********************************************************************/ 
    public class proposalLineItemPayload {
        public Decimal baselineFseReduction {get; set;}
        public Decimal baseLineFseExpanstion {get; set;}
        public Decimal baselineAcvBeforeUplift {get; set;}
        public Decimal targetRenewalAcvUplift {get; set;}
        public Decimal realizedRenewalAcvUplift {get; set;}
        public Decimal baselineFseAdjusted {get; set;}
        public Decimal baselineAcvPepy {get; set;}
        public Decimal realizedRenewalAcvUpliftPepy {get; set;}
        public Decimal addOnNetAcvPepy {get; set;}
        
        public proposalLineItemPayload(
            Decimal baselineFseReduction,
            Decimal baseLineFseExpanstion,
            Decimal baselineAcvBeforeUplift,
            Decimal targetRenewalAcvUplift,
            Decimal realizedRenewalAcvUplift,
            Decimal baselineFseAdjusted,
            Decimal baselineAcvPepy,
            Decimal realizedRenewalAcvUpliftPepy,
            Decimal addOnNetAcvPepy
        ){
            this.baselineFseReduction = baselineFseReduction;
            this.baseLineFseExpanstion = baseLineFseExpanstion;
            this.baselineAcvBeforeUplift = baselineAcvBeforeUplift;
            this.targetRenewalAcvUplift = targetRenewalAcvUplift;
            this.realizedRenewalAcvUplift = realizedRenewalAcvUplift;
            this.baselineFseAdjusted = baselineFseAdjusted;
            this.baselineAcvPepy = baselineAcvPepy;
            this.realizedRenewalAcvUpliftPepy = realizedRenewalAcvUpliftPepy;
            this.addOnNetAcvPepy = addOnNetAcvPepy;
        }
    }
}