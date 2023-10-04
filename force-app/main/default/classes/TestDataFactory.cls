@isTest
public class TestDataFactory {
    /** 
    * ******************************************************
    * This method is test data for create Accounts
    * ******************************************************
    */
    
    public static List<Account> createAccounts(Integer numAccts, Boolean doInsert, String name) {
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < numAccts; i++) {
            Account acc = new Account();
            acc.Name = name;
            accList.add(acc);
        }
        if(doInsert) {
            insert accList;
        }
        return accList;
    }  
    
    /** 
    * ******************************************************
    * This method is test data for create Contacts
    * ******************************************************
    */
    
    public static List<Contact> createContacts(Integer numConts, Boolean doInsert, String lastName, String accountId) {
        List<Contact> contactList = new List<Contact>();
        for(Integer i = 0; i < numConts; i++) {
            Contact con = new Contact();
            con.LastName = lastName;
            con.AccountId = accountId;
            con.Salutation = 'Mr.';
            contactList.add(con);
        }
        if(doInsert) {
            insert contactList;
        }
        return contactList;
    }   
    
    /** 
    * ******************************************************
    * This method is test data for create Applicant/Reviewer User
    * ******************************************************
    */
    public static User createUser(String profile, String username, String contactId) {
        Profile p = [SELECT Id FROM Profile WHERE Name =: profile];
        Blob b = Crypto.GenerateAESKey(128);
      	String h = EncodingUtil.ConvertTohex(b);
      	String uid = h.SubString(0,8);
        User u = new User(
            Alias = uid, 
            Email= uid + '@myorg.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York', 
            UserName= username,
            ContactId = contactId
        );  
        insert u;
        return u;
    }    
    
    /** 
    * ********************************************************************
    * This method is test data for create Regulatory Authorization Types
    * ********************************************************************
    */
    
    public static List<RegulatoryAuthorizationType> createReglAuthTypes(Integer numRegls, Boolean doInsert, String name, String category) {
        List<RegulatoryAuthorizationType> reglAuthTypeList = new List<RegulatoryAuthorizationType>();
        for(Integer i = 0; i < numRegls; i++) {
            RegulatoryAuthorizationType reglAuthType = new RegulatoryAuthorizationType();
            reglAuthType.Name = name;
            reglAuthType.RegulatoryAuthCategory = category;
            reglAuthTypeList.add(reglAuthType);
        }
        if(doInsert) {
            insert reglAuthTypeList;
        }
        return reglAuthTypeList;
    }
    
    /** 
    * ********************************************************
    * This method is test data for create Business Licenses
    * ********************************************************
    */
    
    public static List<BusinessLicense> createBusinessLicenses(Integer numBls, Boolean doInsert, String name, String reglAuthTypeId) {
        List<BusinessLicense> blList = new List<BusinessLicense>();
        for(Integer i = 0; i < numBls; i++) {
            BusinessLicense bl = new BusinessLicense();
            bl.Name = name;
            bl.RegulatoryAuthorizationTypeId = reglAuthTypeId;
            blList.add(bl);
        }
        if(doInsert) {
            insert blList;
        }
        return blList;
    }
    
    /** 
    * *******************************************************************
    * This method is test data for create Business License Applications
    * *******************************************************************
    */
    
    public static List<BusinessLicenseApplication> createBlas(Integer numBlas, Boolean doInsert, String recordType, String licenseTypeId) {
        List<BusinessLicenseApplication> blaList = new List<BusinessLicenseApplication>();
        String recordTypeId = Schema.SObjectType.BusinessLicenseApplication.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        for(Integer i = 0; i < numBlas; i++) {
            BusinessLicenseApplication bla = new BusinessLicenseApplication();
            bla.LicenseTypeId = licenseTypeId;
            bla.AppliedDate = system.now();
            bla.Status = 'Draft';
            bla.Category = 'License';
            bla.RecordTypeId = recordTypeId;
            blaList.add(bla);
        }
        if(doInsert) {
            insert blaList;
        }
        return blaList;
    }
    
    /** 
    * ***********************************************
    * This method is test data for create Locations
    * ***********************************************
    */
    
    public static List<Schema.Location> createLocations(Integer numlocs, Boolean doInsert, String name, String locType, Double lat, Double lng) {
        List<Schema.Location> locationList = new List<Schema.Location>();
        for(Integer i = 0; i < numlocs; i++) {
            Schema.Location loc= new Schema.Location();
            loc.Name = name;
            loc.LocationType = locType;
            loc.Latitude = lat;
            loc.Longitude = lng;
            locationList.add(loc);
        }
        if(doInsert) {
            insert locationList;
        }
        return locationList;
    }
    
    /** 
    * *********************************************************************
    * This method is test data for create Authorization Application Places
    * *********************************************************************
    */
    
    public static List<AuthApplicationPlace> createAuthApplicationPlaces(Integer numplaces, Boolean doInsert, String application, String placeId) {
        List<AuthApplicationPlace> authApplicationPlaceList = new List<AuthApplicationPlace>();
        for(Integer i = 0; i < numplaces; i++) {
            AuthApplicationPlace appPlace = new AuthApplicationPlace();
            appPlace.PlaceId = placeId;
            appPlace.RgltyAuthApplicationId = application;
			authApplicationPlaceList.add(appPlace);            
        }
        if(doInsert) {
            insert authApplicationPlaceList;
        }
        return authApplicationPlaceList;
    }
    
    /** 
    * *****************************************************************************
    * This method is test data for create Authorization Location Access Schedules
    * *****************************************************************************
    */
    
    public static List<AuthLocationAccessSchedule> createAuthLocSchedules(Integer numAlas, Boolean doInsert, String appPlaceId, Date strtDate, Time strtTime, Date endDate, Time endTime) {
        List<AuthLocationAccessSchedule> authLocAccessScheduleList = new List<AuthLocationAccessSchedule>();
        for(Integer i = 0; i < numAlas; i++) {
            AuthLocationAccessSchedule authLoc = new AuthLocationAccessSchedule();
            authLoc.AuthApplPlaceId = appPlaceId;
            authLoc.AuthStartDate = strtDate;
            authLoc.AuthEndDate = endDate;
            authLoc.WorkStartTime = strtTime;
            authLoc.WorkEndTime = endTime;
			authLocAccessScheduleList.add(authLoc);            
        }
        if(doInsert) {
            insert authLocAccessScheduleList;
        }
        return authLocAccessScheduleList;
    }
    
    /** 
    * ***********************************************
    * This method is test data for create Polygons
    * ***********************************************
    */
    
    public static List<Polygon> createPolygons(Integer numPolygons, Boolean doInsert, String name, String dataType, String data) {
        List<Polygon> polygonList = new List<Polygon>();
        for(Integer i = 0; i < numPolygons; i++) {
            Polygon pol = new Polygon();
            pol.Name = name;
            pol.DataType = dataType;
            pol.Data = data;
			polygonList.add(pol);            
        }
        if(doInsert) {
            insert polygonList;
        }
        return polygonList;
    }	
    
    /** 
    * ********************************************************
    * This method is test data for create Polygon Schedules
    * ********************************************************
    */
    
    public static List<Polygon_Schedule__c> createPolygonSchedules(Integer numps, Boolean doInsert, String name, String polygonId, String locAccSchId) {
        List<Polygon_Schedule__c> psList = new List<Polygon_Schedule__c>();
        for(Integer i = 0; i < numps; i++) {
            Polygon_Schedule__c ps = new Polygon_Schedule__c();
            ps.Name = name;
            ps.Polygon__c = polygonId;
            ps.Authorization_Location_Access_Schedule__c = locAccSchId;
			psList.add(ps);            
        }
        if(doInsert) {
            insert psList;
        }
        return psList;
    }
    
    /** 
    * *******************************************
    * This method is test data for create Tasks
    * *******************************************
    */
    
    public static List<Task> createTasks(Integer numtasks, Boolean doInsert, String subject, String whatId, String status) {
        List<Task> taskList = new List<Task>();
        for(Integer i = 0; i < numtasks; i++) {
            Task t = new Task();
            t.Subject = subject;
            t.WhatId = whatId;
            t.Status = status;
			taskList.add(t);            
        }
        if(doInsert) {
            insert taskList;
        }
        return taskList;
    }
}