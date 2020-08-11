public with sharing class pageurlclass{
 
         /**
         * Webkul Software.
         *
         * @category  Webkul
         * @author    Webkul
         * @copyright Copyright (c) 2010-2016 Webkul Software Private Limited (https://webkul.com)
         * @license   https://store.webkul.com/license.html
         */
 
    public  String  headerdata{get;set;}
    public string urlvalue{get;set;}
    public string url{get;set;}
         
    public pageurlclass(){
         
         headerdata= ApexPages.currentPage().getHeaders().get('Host');
         
         urlvalue=Apexpages.currentPage().getUrl();
         
         url='https://' + headerdata+ urlvalue;
    }
   
 
}