public without sharing class Applicant_License_Approved_Ctr { // Query: Sharing False Positive: the class job is to retrieve all the polygon records regardless of user permissions
    public String apiKey{get;set;}
    
    public String baseMapLayer{get;set;}
    
    public String outLineColor{get;set;}
    
    Id polySchRecId;
    public String strCurPolyRec {get;set;}
    
    public String strLatitude {get; set;}
    public String strLongitude {get; set;}
    
    public Applicant_License_Approved_Ctr(){
        // Get api Key
        apiKey = utils__mdt.getInstance('ApiKey').Value__c;
        
        baseMapLayer = utils__mdt.getInstance('LicenseApprovedBaseMapLayer').Value__c;
        
        // Get Business License Approved Polygon Outline Color
        outLineColor = utils__mdt.getInstance('LicenseApprovedPolygonOutlineColor').Value__c;
        
        String parameterValue = ApexPages.currentPage().getParameters().get('authLocationId');
		List<Polygon_Schedule__c> objSch = [SELECT Status__c,Comments__c,Polygon__c, Polygon__r.Data,Polygon__r.Altered_Data__c,
                                                Authorization_Location_Access_Schedule__r.AuthStartDate,
                                                Authorization_Location_Access_Schedule__r.AuthEndDate, 
                                                Authorization_Location_Access_Schedule__r.WorkStartTime, 
                                                Authorization_Location_Access_Schedule__r.WorkEndTime,
                                                Authorization_Location_Access_Schedule__r.AuthApplPlace.PlaceId
                                                FROM Polygon_Schedule__c 
                                                WHERE Authorization_Location_Access_Schedule__c =: parameterValue 
                                                AND Status__c =: utils__mdt.getInstance('PS_Approved_Status').Value__c];
        strCurPolyRec = JSON.serialize(objSch);
        if(!objSch.isEmpty()) {
            Schema.Location objLoc = [SELECT Latitude, Longitude FROM Location WHERE Id =: objSch[0].Authorization_Location_Access_Schedule__r.AuthApplPlace.PlaceId];
            strLatitude = String.ValueOf(objLoc.Latitude);
            strLongitude = String.ValueOf(objLoc.Longitude);
        }
    }
    
    @AuraEnabled
    public static List<String> getLocationchedules(String recordId) {
        Set<String> authLocationAccessScheduleIdSet = new Set<String>();
        for(Polygon_Schedule__c ps : [SELECT Id,Status__c,Authorization_Location_Access_Schedule__c,Business_License__c
                                      FROM Polygon_Schedule__c 
                                      WHERE Business_License__c =: recordId AND Status__c = 'Approved']) {
            authLocationAccessScheduleIdSet.add(ps.Authorization_Location_Access_Schedule__c);
        }
        return new List<String>(authLocationAccessScheduleIdSet);
    }
}