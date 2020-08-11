Public class NewCaseListController {
List<Case> results = new List<Case>();


private String sortOrder = 'CaseNumber';
public List<Case> getNewCases() {
    
    results = [SELECT Id, CaseNumber FROM Case WHERE Status = 'New'];

    return results;
    }
}
/**public class NewCaseListController {
    public  List<Case> getNewCases (){
        List<Case> results = Database.query(
            'SELECT Id, CaseNumber  ' +
            'FROM Case ' +
            'where status =\'New\''
        );
        return results;
    }

}
**/