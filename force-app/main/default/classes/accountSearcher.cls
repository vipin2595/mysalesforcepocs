public class accountSearcher{

    public Decimal a { get; set; }
    
    public Double SellingTerm1 { get; set; }
    public String Frequency { get; set; }
    public static Date startDate{get;set;}
    public static Date endDate{get;set;}
    public integer SellingTerm{set;get;}
    public integer startDaysInMonth1{set;get;}
    public integer endDaysInMonth1{set;get;}
    public integer SellingMonths1{set;get;}
    public decimal sellingProratedStart1{set;get;}
    public decimal sellingProratedEnd1{set;get;}
    public decimal CalculatedSellingTermMonth1{set;get;}
    public Integer startDay1{set;get;}
    public Integer endDay1{set;get;}
    
    public void searchAccount(){
        system.debug('**startDate'+ ' '+startDate);
        system.debug('Frequency'+ ' '+Frequency);
        Date StartDate = startDate;
        System.debug('xx' + StartDate);
        Date EndDate = endDate;
        System.debug('xx' + EndDate);
        
        Double SellingTerm;
        String Frequency = Frequency;
        Integer startYear = StartDate.year();
        Integer startMonth = StartDate.Month();
        Integer startDay = StartDate.Day();
        startDay1 = startDay;
        Integer startDaysInMonth = date.daysInMonth(startYear,startMonth);
        system.debug('**startDaysInMonth'+ ' '+startDaysInMonth);
        startDaysInMonth1 = startDaysInMonth;
        Integer endYear = EndDate.year();
        Integer endMonth = EndDate.Month();
        Integer endDay = EndDate.Day();
        endDay1 = endDay;
        Integer endDaysInMonth = date.daysInMonth(endYear,endMonth);
        endDaysInMonth1 = endDaysInMonth;
        System.debug(' StartDate.Day();' + startDay);
        System.debug(' EndDay.Day();' + endDay);
        
        Integer sellingMonths = StartDate.monthsBetween(EndDate)-1;
        SellingMonths1 = sellingMonths;
        System.debug('Start Days in month: ' + date.daysInMonth(startYear,startMonth));
        system.debug('part 1: ' + (date.daysInMonth(startYear,startMonth)-startDay+1.00000));
        system.debug('part 2: ' + (1.00000*date.daysInMonth(startYear,startMonth)));
        
        
        Decimal sellingProratedStart = ((date.daysInMonth(startYear,startMonth)-startDay+1.00)*1.00)/(1.00*date.daysInMonth(startYear,startMonth));
        sellingProratedStart1 =sellingProratedStart;
        system.debug('sellingProratedStart' + sellingProratedStart);
        
        Decimal sellingProratedEnd = (endDay*1.00)/(1.00*date.daysInMonth(endYear,endMonth));
        sellingProratedEnd1 = sellingProratedEnd;
        Decimal CalculatedSellingTermMonth = sellingProratedStart+sellingMonths+sellingProratedEnd;
        CalculatedSellingTermMonth1 = CalculatedSellingTermMonth;
        system.debug('sellingMonths' + sellingMonths);
        system.debug('sellingProratedStart' + sellingProratedStart);
        system.debug('sellingProratedEnd' + sellingProratedEnd);
        a = sellingProratedStart+sellingProratedEnd;
        system.debug('**add'+a);
        system.debug('CalculatedSellingTermMonth' + CalculatedSellingTermMonth);
        system.debug('Frequency'+ ' '+Frequency);
        if (Frequency == 'Monthly') {
            SellingTerm = CalculatedSellingTermMonth;
        } else if (Frequency == 'Yearly'){
            SellingTerm = CalculatedSellingTermMonth/12.00;
        } else if (Frequency == 'Half Yearly'){
            SellingTerm = CalculatedSellingTermMonth/6.00;
        } else if (Frequency == 'Quarterly'){
            SellingTerm = CalculatedSellingTermMonth/4.00;
        } else {
            SellingTerm = 1.00;
        }
        system.debug('Frequency'+ ' '+ Frequency);
        system.debug('SellingTerm'+ ' '+ SellingTerm);
        SellingTerm1= SellingTerm;
        
    }
    public void reset(){
        startDate=null;
        endDate=null;
        SellingTerm1=null;
        Frequency=null; 
        startDaysInMonth1=null;
        endDaysInMonth1=null;
        SellingMonths1=null;
        sellingProratedStart1=null;
        sellingProratedEnd1=null;
        CalculatedSellingTermMonth1=null;
        startDay1=null;
        endDay1=null;
        a=null;
    }
}