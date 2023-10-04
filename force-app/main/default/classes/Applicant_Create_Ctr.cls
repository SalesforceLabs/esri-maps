public without sharing class Applicant_Create_Ctr {// Query: Sharing False Positive: the class job is to retrieve all the polygon records regardless of user permissions
    public String apiKey{get;set;}
    
    public String communityUrl{get;set;}
    
    public String existingPolygonColor{get;set;}
    public String existingPolygonOutLineColor{get;set;}
    public String validDrawnPolygonColor{get;set;}
    public String validDrawnPolygonOutLineColor{get;set;}
    public String invalidDrawnPolygonColor{get;set;}
    public String invalidDrawnPolygonOutLineColor{get;set;}
    
    public String validPolygonStyle{get;set;}
    public String invalidPolygonStyle{get;set;}
    
    public String allPolygons {get; set;}
    public String schDetails {get; set;}
    public String strDtStrt {get; set;}
    public String strDtEnd {get; set;}
    Date dtStrt,dtEnd;
    public Time timeStrt{get; set;}
    public Time timeEnd{get; set;}

    public Applicant_Create_Ctr(){
        // Get api Key
        apiKey = utils__mdt.getInstance('ApiKey').Value__c;
        
        fetchCommunityURL();
        
        // Get Site url
        communityUrl = fetchCommunityURL();
        
        // Get Existing Polygons Color and outline colors
        existingPolygonColor = utils__mdt.getInstance('ExistingPolygonColor').Value__c;
        existingPolygonOutLineColor = utils__mdt.getInstance('ExistingPolygonOutLineColor').Value__c;
        validDrawnPolygonColor = utils__mdt.getInstance('ValidDrawnPolygonColor').Value__c;
        validDrawnPolygonOutLineColor = utils__mdt.getInstance('ValidDrawnPolygonOutLineColor').Value__c;
        invalidDrawnPolygonColor = utils__mdt.getInstance('InvalidDrawnPolygonColor').Value__c;
        invalidDrawnPolygonOutLineColor = utils__mdt.getInstance('InvalidDrawnPolygonOutLineColor').Value__c;
        
        // Polygon Styles
        validPolygonStyle = utils__mdt.getInstance('validPolygonStyle').Value__c;
        invalidPolygonStyle = utils__mdt.getInstance('InvalidPolygonStyle').Value__c;
        
        loadPolygons();
    }
    public void fetchTimeDetails(){
        Map<String, Object> mapDetails = (Map<String,Object>)JSON.deserializeUntyped(schDetails);
        
        dtStrt = Date.valueOf((String)mapDetails.get('strtDate'));
        dtEnd =  Date.valueOf((String)mapDetails.get('endDate'));

        String strStTime = (String)mapDetails.get('strtTime');
        String strEndTime = (String)mapDetails.get('endTime');
        
        timeStrt = Time.newInstance(Integer.valueOf(strStTime.subStringBefore(':')), Integer.valueOf(strStTime.subStringBetween(':')), 0, 0);
        timeEnd = Time.newInstance(Integer.valueOf(strEndTime.subStringBefore(':')), Integer.valueOf(strEndTime.subStringBetween(':')), 0, 0);
        
        strDtStrt = String.valueOf(dtStrt);
        strDtEnd = String.valueOf(dtEnd);

        loadPolygons();
    }
    
    public String strLat{get {return String.IsBlank(strLat) ? Utils__mdt.getInstance('Default_Latitude').Value__c : strLat; } set; }
    public String strLon{get {return String.IsBlank(strLon) ? Utils__mdt.getInstance('Default_Longitude').Value__c : strLon; } set; }
    
    @AuraEnabled
    public static String fetchCommunityURL(){
        Site s = [SELECT Id, Name FROM Site where Name =: utils__mdt.getInstance('SiteName').Value__c];
        SiteDetail sd = [select SecureURL from SiteDetail where DurableId =: s.Id];
        return sd.SecureURL.removeEnd('/');
    }
    
    public void loadPolygons(){
        List<Polygon_Schedule__c> lstPSchedule = new List<Polygon_Schedule__c>();
        for(Polygon_Schedule__c objPSchedule : [SELECT Polygon__c, Polygon__r.Data, Polygon__r.Altered_Data__c,
                                                Authorization_Location_Access_Schedule__r.AuthStartDate,
                                                Authorization_Location_Access_Schedule__r.AuthEndDate, 
                                                Authorization_Location_Access_Schedule__r.WorkStartTime, 
                                                Authorization_Location_Access_Schedule__r.WorkEndTime
                                                FROM Polygon_Schedule__c WHERE 
                                                Status__c =: Utils__mdt.getInstance('PS_Approved_Status').Value__c AND 
                                                ((Authorization_Location_Access_Schedule__r.AuthStartDate <= :dtStrt AND
                                                 Authorization_Location_Access_Schedule__r.AuthEndDate >= : dtStrt) OR
                                                (Authorization_Location_Access_Schedule__r.AuthStartDate <= :dtEnd AND
                                                 Authorization_Location_Access_Schedule__r.AuthEndDate >= :dtEnd) OR 
                                                 (Authorization_Location_Access_Schedule__r.AuthStartDate >= :dtStrt AND
                                                 Authorization_Location_Access_Schedule__r.AuthEndDate <= :dtEnd)) LIMIT 50000]){
                                                    if(dtStrt <= objPSchedule.Authorization_Location_Access_Schedule__r.AuthEndDate &&
                                                       dtEnd >= objPSchedule.Authorization_Location_Access_Schedule__r.AuthStartDate &&
                                                       ((dtStrt < objPSchedule.Authorization_Location_Access_Schedule__r.AuthEndDate) ||
                                                        (dtStrt == objPSchedule.Authorization_Location_Access_Schedule__r.AuthEndDate &&
                                                         timeStrt <= objPSchedule.Authorization_Location_Access_Schedule__r.WorkEndTime)) &&
                                                       ((dtEnd > objPSchedule.Authorization_Location_Access_Schedule__r.AuthStartDate) ||
                                                        (dtEnd == objPSchedule.Authorization_Location_Access_Schedule__r.AuthStartDate &&
                                                         timeEnd >= objPSchedule.Authorization_Location_Access_Schedule__r.WorkStartTime))) {
                                                             lstPSchedule.add(objPSchedule);
                                                         }
                                                } 
            allPolygons = JSON.serialize(lstPSchedule);
    }
}