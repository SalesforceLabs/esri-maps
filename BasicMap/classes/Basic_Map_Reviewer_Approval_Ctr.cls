public with sharing class Basic_Map_Reviewer_Approval_Ctr {
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
        
    public String strLatitude {get; set;}
    public String strLongitude {get; set;}
    
    String strRecId;
    public String strData {get; set;}
    public String strPolygonUpdStatus {get; set;}
    public String strAcceptedValues {get; set;}
    public string lexOrigin {get{ 
        return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';
    } set;}
    
    public Basic_Map_Reviewer_Approval_Ctr(){
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
        featureLayers = JSON.serialize([SELECT Id, url__c, visible__c, renderer__c, popupTemplate__c FROM Feature_Layers__mdt WHERE url__c != NULL WITH SECURITY_ENFORCED]);
        
        // Get Polygon Schedule Records
        String BLAId = ApexPages.currentPage().getParameters().get('recordId');
        Polygon_Schedule__c objSch = [SELECT Polygon__c, Polygon__r.Data, Polygon__r.Altered_Data__c, Id
                                                FROM Polygon_Schedule__c WHERE BLA_Id__c =: BLAId WITH SECURITY_ENFORCED LIMIT 1];
                                                
        polySchRecId = objSch.Id;
                                            
        strCurPolyRec = JSON.serialize(objSch);
        
        Schema.AuthApplicationPlace placeLoc = [SELECT PlaceId from AuthApplicationPlace WHERE RgltyAuthApplicationId =: BLAId WITH SECURITY_ENFORCED];
        String strPlaceId = String.ValueOf(placeLoc.PlaceId);
        
        Schema.Location objLoc = [SELECT Latitude, Longitude FROM Location WHERE Id =: strPlaceId WITH SECURITY_ENFORCED];
        strLatitude = String.ValueOf(objLoc.Latitude);
        strLongitude = String.ValueOf(objLoc.Longitude);
        strRecId = objSch.Polygon__c;

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
    public static Polygon_Schedule__c getPolygonSchedule(String recordId) {
            
        return [SELECT Id, Polygon__c, Polygon__r.Data,
                Status__c,
                Review_Completed__c
                FROM Polygon_Schedule__c 
                WHERE 
                BLA_Id__c =: recordId WITH SECURITY_ENFORCED LIMIT 1];
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
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, new List<Polygon>{objP});
            update securityDecision.getRecords();
            strPolygonUpdStatus = 'Update succesful';
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }
    }
}