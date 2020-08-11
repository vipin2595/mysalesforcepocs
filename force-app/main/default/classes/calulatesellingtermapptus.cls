public class calulatesellingtermapptus {

    public string Startdate{set;get;}
    
    //public integer bval{set;get;}
    //public Date Enddate{set;get;}
     public integer aval{set;get;}
     
     public integer Cval{set;get;}
    public  calulatesellingtermapptus(){
     system.debug('Startdate'+Startdate);
       //  system.debug('Enddate'+Enddate);
    }
    public void ADD(){
        system.debug('Cval'+Cval);
        system.debug('Startdate'+Startdate);
         //system.debug('Enddate'+Enddate);
       // Cval = Startdate.monthsBetween(Enddate);
        //cval=aval+bval;
        /*Date StartDate = Date.newInstance(2016, 6, 23);
        System.debug('xx' + StartDate);
        Date EndDate = Date.newInstance(2017, 1, 31);
        System.debug('xx' + EndDate);
        
        Double SellingTerm;
        String Frequency = 'Yearly';
        Integer startYear = StartDate.year();
        Integer startMonth = StartDate.Month();
        Integer startDay = StartDate.Day();
        Integer startDaysInMonth = date.daysInMonth(startYear,startMonth);
        
        Integer endYear = EndDate.year();
        Integer endMonth = EndDate.Month();
        Integer endDay = EndDate.Day();
        Integer endDaysInMonth = date.daysInMonth(endYear,endMonth);
        
        System.debug(' StartDate.Day();' + startDay);
        System.debug(' EndDay.Day();' + endDay);
        
        Integer sellingMonths = StartDate.monthsBetween(EndDate)-1;
        
        System.debug('Start Days in month: ' + date.daysInMonth(startYear,startMonth));
        system.debug('part 1: ' + (date.daysInMonth(startYear,startMonth)-startDay+1.00000));
        system.debug('part 2: ' + (1.00000*date.daysInMonth(startYear,startMonth)));
        
        
        Decimal sellingProratedStart = ((date.daysInMonth(startYear,startMonth)-startDay+1.00)*1.00)/(1.00*date.daysInMonth(startYear,startMonth));
        
        system.debug('sellingProratedStart' + sellingProratedStart);
        
        Decimal sellingProratedEnd = (endDay*1.00)/(1.00*date.daysInMonth(endYear,endMonth));
        Decimal CalculatedSellingTermMonth = sellingProratedStart+sellingMonths+sellingProratedEnd;
        system.debug('sellingMonths' + sellingMonths);
        system.debug('sellingProratedStart' + sellingProratedStart);
        system.debug('sellingProratedEnd' + sellingProratedEnd);
        system.debug('CalculatedSellingTermMonth' + CalculatedSellingTermMonth);
        
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
        */
    }
    public void reset(){
        Startdate=null;
       // Enddate=null;
        //cval=null;
    }
    
    
}