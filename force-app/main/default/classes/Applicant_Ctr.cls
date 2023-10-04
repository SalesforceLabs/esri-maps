public without sharing class Applicant_Ctr {
    public String apiKey{get;set;}
    
    public String baseMapLayer{get;set;}
    
    public String outLineColor{get;set;}
    public String reviewerOtherPolygonsOutlineColor{get; set;}
    
    Id polySchRecId;
    public String strCurPolyRec {get;set;}
    
    public String strLatitude {get; set;}
    public String strLongitude {get; set;}
    
    public Applicant_Ctr(){
        // Get api Key
        apiKey = utils__mdt.getInstance('ApiKey').Value__c;
        
        baseMapLayer = utils__mdt.getInstance('ApplicantBaseMapLayer').Value__c;
        
        // Get Applicant Polygon Outline Color
        outLineColor = utils__mdt.getInstance('ApplicantPolygonOutLineColor').Value__c;
        reviewerOtherPolygonsOutlineColor = utils__mdt.getInstance('ReviewerOtherPolygonsOutlineColor').Value__c;
        
        String parameterValue = ApexPages.currentPage().getParameters().get('authLocationId');
		List<Polygon_Schedule__c> objSch = [SELECT Status__c,Comments__c,Polygon__c, Polygon__r.Data, Polygon__r.Altered_Data__c,
                                                Authorization_Location_Access_Schedule__r.AuthStartDate,
                                                Authorization_Location_Access_Schedule__r.AuthEndDate, 
                                                Authorization_Location_Access_Schedule__r.WorkStartTime, 
                                                Authorization_Location_Access_Schedule__r.WorkEndTime,
                                                Authorization_Location_Access_Schedule__r.AuthApplPlace.PlaceId
                                                FROM Polygon_Schedule__c WHERE Authorization_Location_Access_Schedule__c =: parameterValue];
        strCurPolyRec = JSON.serialize(objSch);
        if(!objSch.isEmpty()) {
            Schema.Location objLoc = [SELECT Latitude, Longitude FROM Location WHERE Id =: objSch[0].Authorization_Location_Access_Schedule__r.AuthApplPlace.PlaceId];
            strLatitude = String.ValueOf(objLoc.Latitude);
            strLongitude = String.ValueOf(objLoc.Longitude);
        }
    }
    
    @AuraEnabled
    public static List<AuthLocationAccessSchedule> getPolySchdules(Id recordId){
        return [SELECT Id,AuthStartDate, AuthEndDate, WorkStartTime, WorkEndTime
                FROM AuthLocationAccessSchedule 
                WHERE AuthApplPlace.RgltyAuthApplicationId =: recordId];
    }
}