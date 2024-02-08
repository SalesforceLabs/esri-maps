public with sharing class Basic_Map_Ctr {
    public String apiKey{get;set;}
    
    public String baseMapLayer{get;set;}
    
    public String outLineColor{get;set;}
    public String reviewerOtherPolygonsOutlineColor{get; set;}
    
    Id polySchRecId;
    public String strCurPolyRec {get;set;}
    
    public String strLatitude {get; set;}
    public String strLongitude {get; set;}
    
    public Basic_Map_Ctr(){
        // Get api Key
        apiKey = utils__mdt.getInstance('ApiKey').Value__c;
        
        baseMapLayer = utils__mdt.getInstance('ApplicantBaseMapLayer').Value__c;
        
        // Get Applicant Polygon Outline Color
        outLineColor = utils__mdt.getInstance('ApplicantPolygonOutLineColor').Value__c;
        reviewerOtherPolygonsOutlineColor = utils__mdt.getInstance('ReviewerOtherPolygonsOutlineColor').Value__c;
        
        String parameterValue = ApexPages.currentPage().getParameters().get('applicationId');
        List<Polygon_Schedule__c> objSch = [SELECT Status__c,Comments__c,Polygon__c, Polygon__r.Data, Polygon__r.Altered_Data__c
                                                FROM Polygon_Schedule__c WHERE BLA_Id__c =: parameterValue WITH SECURITY_ENFORCED];
        strCurPolyRec = JSON.serialize(objSch);
        if(!objSch.isEmpty()) {
            Schema.AuthApplicationPlace placeLoc = [SELECT PlaceId from AuthApplicationPlace WHERE RgltyAuthApplicationId =: parameterValue WITH SECURITY_ENFORCED];
            String strPlaceId = String.ValueOf(placeLoc.PlaceId);
            
        
            Schema.Location objLoc = [SELECT Latitude, Longitude FROM Location WHERE Id =: strPlaceId WITH SECURITY_ENFORCED];
            strLatitude = String.ValueOf(objLoc.Latitude);
            strLongitude = String.ValueOf(objLoc.Longitude);
        }
    }
    

}