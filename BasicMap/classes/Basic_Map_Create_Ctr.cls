global with sharing class Basic_Map_Create_Ctr {// Query: Sharing False Positive: the class job is to retrieve all the polygon records regardless of user permissions
    global String apiKey{get;set;}
    
    public String schDetails {get; set;}
    global String defaultlat {get; set;}
    global String defaultlng {get; set;}
    

    global Basic_Map_Create_Ctr(){
        // Get api Key
        apiKey = utils__mdt.getInstance('ApiKey').Value__c;
 
        defaultlat = ApexPages.currentPage().getParameters().get('latitude');
        defaultlng = ApexPages.currentPage().getParameters().get('longitude');
    }
    global void fetchTimeDetails(){
   
        String[] coords = schDetails.split('|');
        defaultlng = coords[0];
        defaultlat = coords[1];
    

    }
    
    global String strLat{get {return String.IsBlank(strLat) ? Utils__mdt.getInstance('Default_Latitude').Value__c : strLat; } set; }
    global String strLon{get {return String.IsBlank(strLon) ? Utils__mdt.getInstance('Default_Longitude').Value__c : strLon; } set; }
    
 
    

}