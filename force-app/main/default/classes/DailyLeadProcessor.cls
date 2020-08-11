global class DailyLeadProcessor implements Schedulable{
    
    global void execute(SchedulableContext ctx){
        List<Lead> LeaDList = new list<Lead>();
        for(Lead LD : [Select id from Lead where LeadSource =null]){
            Lead LeD = new Lead(id=LD.id);
            LeD.LeadSource='Dreamforce';
            LeaDList.add(LeD);
        }
        Update LeaDList; 
    }

}