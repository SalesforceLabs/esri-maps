public without sharing class Reviewer_Approval_Ctr {
    public String apiKey{get;set;}
    
    public String featureLayers{get; set;}
    
    public String baseMapLayer{get;set;}
    
    public String communityUrl{get;set;}
    public String internalUrl{get;set;}
    
    public String validPolygonStyle{get;set;}
    public String invalidPolygonStyle{get;set;}
    
    public String validPolygonColor{get;set;}
    public String validPolygonOutLineColor{get;set;}
    public String invalidPolygonColor{get;set;}
    public String invalidPolygonOutLineColor{get;set;}
    public String reviewerOtherPolygonsOutlineColor{get;set;}
    public String reviewerCurrentPolygonOutlineColor{get;set;}
    
    public String polySchRecId{get; set;}
    public String strCurPolyRec {get;set;}
    public String strRelatedPolyRecs {get; set;}
    
    public String strLatitude {get; set;}
    public String strLongitude {get; set;}
    
    String strRecId;
    public String strData {get; set;}
    public String strPolygonUpdStatus {get; set;}
    public String strAcceptedValues {get; set;}
    public string lexOrigin {get{ 
        return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';
    } set;}
    
    public Reviewer_Approval_Ctr(){
        // Get api Key
        apiKey = utils__mdt.getInstance('ApiKey').Value__c;
        system.debug(URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com');
        baseMapLayer = utils__mdt.getInstance('ReviewerBaseMapLayer').Value__c;
        
        // Get Polygon Styles
        validPolygonStyle = utils__mdt.getInstance('validPolygonStyle').Value__c;
        invalidPolygonStyle = utils__mdt.getInstance('InvalidPolygonStyle').Value__c;
        
        // Get Polygon Colors
        validPolygonColor = utils__mdt.getInstance('ValidDrawnPolygonColor').Value__c;
        validPolygonOutLineColor = utils__mdt.getInstance('ValidDrawnPolygonOutLineColor').Value__c;
        invalidPolygonColor = utils__mdt.getInstance('InvalidDrawnPolygonColor').Value__c;
        invalidPolygonOutLineColor = utils__mdt.getInstance('InvalidDrawnPolygonOutLineColor').Value__c;
        reviewerOtherPolygonsOutlineColor = utils__mdt.getInstance('ReviewerOtherPolygonsOutlineColor').Value__c;
        reviewerCurrentPolygonOutlineColor = utils__mdt.getInstance('ReviewerCurrentPolygonOutlineColor').Value__c;
        
        strAcceptedValues = Utils__mdt.getInstance('PS_Approved_Status').Value__c;
        // Get Site url
        Site s = [SELECT Id, Name FROM Site where Name =: utils__mdt.getInstance('SiteName').Value__c];
        SiteDetail sd = [select SecureURL from SiteDetail where DurableId =: s.Id];
        communityUrl = sd.SecureURL.removeEnd('/');
        
        // Internal URL
        internalUrl = 'https://'+ URL.getOrgDomainUrl().getHost().split('\\.')[0].toLowerCase()+ '.lightning.force.com';
        
        // Get Feature Layers
        featureLayers = JSON.serialize([SELECT Id, url__c, visible__c, renderer__c, popupTemplate__c FROM Feature_Layers__mdt WHERE url__c != NULL]);
        
        // Get Polygon Schedule Records
        polySchRecId = ApexPages.currentPage().getParameters().get('polySchId');
        Polygon_Schedule__c objSch = [SELECT Polygon__c, Polygon__r.Data, Polygon__r.Altered_Data__c,
                                                Authorization_Location_Access_Schedule__r.AuthStartDate,
                                                Authorization_Location_Access_Schedule__r.AuthEndDate, 
                                                Authorization_Location_Access_Schedule__r.WorkStartTime, 
                                                Authorization_Location_Access_Schedule__r.WorkEndTime,
                                                Authorization_Location_Access_Schedule__r.AuthApplPlace.PlaceId
                                                FROM Polygon_Schedule__c WHERE Id=: polySchRecId];
        strCurPolyRec = JSON.serialize(objSch);
        
        Schema.Location objLoc = [SELECT Latitude, Longitude FROM Location WHERE Id =: objSch.Authorization_Location_Access_Schedule__r.AuthApplPlace.PlaceId];
        strLatitude = String.ValueOf(objLoc.Latitude);
        strLongitude = String.ValueOf(objLoc.Longitude);
        strRecId = objSch.Polygon__c;
        
        Date dtStrt = objSch.Authorization_Location_Access_Schedule__r.AuthStartDate;
        Date dtEnd = objSch.Authorization_Location_Access_Schedule__r.AuthEndDate;
        
        Time timeStrt = objSch.Authorization_Location_Access_Schedule__r.WorkStartTime;
        Time timeEnd = objSch.Authorization_Location_Access_Schedule__r.WorkEndTime;
        
        List<Polygon_Schedule__c> lstPSchedule = new List<Polygon_Schedule__c>();
        
        List<String> lstRejValues = Utils__mdt.getInstance('PS_Rejected_Status').Value__c.split(',');
        for(Polygon_Schedule__c objPSchedule : [SELECT Polygon__c, Polygon__r.Data,Polygon__r.Altered_Data__c, 
                                                Authorization_Location_Access_Schedule__r.AuthStartDate,
                                                Authorization_Location_Access_Schedule__r.AuthEndDate, 
                                                Authorization_Location_Access_Schedule__r.WorkStartTime, 
                                                Authorization_Location_Access_Schedule__r.WorkEndTime,
                                                Status__c,
                                                Review_Completed__c 
                                                FROM Polygon_Schedule__c
                                                WHERE
                                                Id <> :polySchRecId AND 
                                                Status__c NOT IN :lstRejValues AND 
                                                ((Authorization_Location_Access_Schedule__r.AuthStartDate <= :dtStrt AND
                                                 Authorization_Location_Access_Schedule__r.AuthEndDate >= : dtStrt) OR
                                                (Authorization_Location_Access_Schedule__r.AuthStartDate <= :dtEnd AND
                                                 Authorization_Location_Access_Schedule__r.AuthEndDate >= :dtEnd
                                                )) LIMIT 50000]){
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
        strRelatedPolyRecs = JSON.serialize(lstPSchedule);
    }
    
    @AuraEnabled
    public static List<Polygon_Schedule__c> getPolySchdules(String taskId){
        Id applId = [SELECT Id, WhatId FROM Task WHERE Id=: taskId]?.WhatId;
        return [SELECT Id, Polygon__c, Polygon__r.Data, Authorization_Location_Access_Schedule__c, Authorization_Location_Access_Schedule__r.AuthStartDate,
                Authorization_Location_Access_Schedule__r.AuthEndDate, 
                Authorization_Location_Access_Schedule__r.WorkStartTime, 
                Authorization_Location_Access_Schedule__r.WorkEndTime,
                Status__c,
                Review_Completed__c
                FROM Polygon_Schedule__c 
                WHERE 
                Authorization_Location_Access_Schedule__r.AuthApplPlace.RgltyAuthApplicationId =: applId];
    }
    
    @AuraEnabled
    public static void updateScheduleStatus(Id recordId, String statusVal){
        Polygon_Schedule__c objPS = new Polygon_Schedule__c();
        objPS.Status__c = statusVal;
        objPS.Id = recordId;
        try {
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, new List<Polygon_Schedule__c>{objPS});
            update securityDecision.getRecords();
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getApplicantEmail(String recordId) {
        Id applId = [SELECT Id, WhatId FROM Task WHERE Id=: recordId]?.WhatId;
        String applicantId = [SELECT Id, ApplicantId FROM BusinessLicenseApplication WHERE Id =: applId]?.ApplicantId;
        if(String.isNotBlank(applicantId)) {
            return [SELECT Id, Email, ContactId FROM User WHERE ContactId =: applicantId]?.Email;
        }
        return '';
    }
    
    @AuraEnabled
    public static String fetchVFDomainURL(){
        String strURL = 'https://'+DomainCreator.getVisualforceHostname('');
        return strURL;
    }
    
    public void updatePolygon(){
        try {
            Polygon objP = new Polygon();
            system.debug(strData);
            objP.Altered_Data__c = strData;
            objP.Id = strRecId;
            update objP;
            strPolygonUpdStatus = 'Update succesful';
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }
    }
}