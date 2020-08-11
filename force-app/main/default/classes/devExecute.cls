IF(
    AND(
    IsPickval(Menu_Status__c,'Questionnaire Created'), 
    IsBlank(Hours_spent_by_MS_on_Questionnaire__c), 
    IsBlank(of_Questions_Asked__c), 
    IsBlank(Menu_Preparation_Folder_Box_Link__c)
    ), true, false
)

IF(NOT(IsPickval( Menu_Status__c,'Questionnaire Created')), true, 
    IF(NOT(ISNULL(Hours_spent_by_MS_on_Questionnaire__c)), true, 
        IF(NOT(ISNULL(Menu_Preparation_Folder_Box_Link__c)), true, 
            IF(NOT(ISNULL(of_Questions_Asked__c)), true, false ) 
        )
    )
)

IF(NOT(IsPickval( Menu_Status__c,'Questionnaire Created')), true, 
    IF(AND(ISNULL(Hours_spent_by_MS_on_Questionnaire__c), ISNULL(Menu_Preparation_Folder_Box_Link__c),ISNULL(of_Questions_Asked__c)), true, false
)

IF(NOT(IsPickval( Menu_Status__c,'Questionnaire Created')), true, 
    IF(
        ISBLANK(Hours_spent_by_MS_on_Questionnaire__c) && ISBLANK(of_Questions_Asked__c) && ISBLANK(Menu_Preparation_Folder_Box_Link__c)
    , false, true)
)

t,t,t --> f --> t
t,f,t --> true --> false

IF(NOT(IsPickval( Menu_Status__c,'Questionnaire Created')), true, 
    IF(
        ISBLANK(Hours_spent_by_MS_on_Questionnaire__c)
    , IF(
        ISBLANK(of_Questions_Asked__c), true
    )
)


NOT(
    IF(
        IsPickval( Menu_Status__c,'Questionnaire Created'), 
        IF(
            NOT(
                ISBLANK(Hours_spent_by_MS_on_Questionnaire__c) && ISBLANK(of_Questions_Asked__c) && ISBLANK(Menu_Preparation_Folder_Box_Link__c)
            ), true, false
        ),
        false
    )
)
T,F,F -- > F --> T --> F
T,F,F -- > F --> T 



IF(
    NOT(IsPickval( Menu_Status__c,'Questionnaire Created')), false,
    NOT(IF( 
        AND(NOT(ISBLANK(Hours_spent_by_MS_on_Questionnaire__c)), NOT(ISBLANK(of_Questions_Asked__c) ), NOT(ISBLANK(Menu_Preparation_Folder_Box_Link__c) )), true, false 
    ))
)

T,t --> true --> false
T,F --> F --> true

f,f --> 