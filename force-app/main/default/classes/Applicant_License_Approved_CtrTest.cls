@isTest
public class Applicant_License_Approved_CtrTest {
    @TestSetup
    static void setupData() {
        List<Account> accList = TestDataFactory.createAccounts(1, true, 'test');
        List<Contact> conList = TestDataFactory.createContacts(1, true, 'test last name', accList[0].Id);
        User usr = TestDataFactory.createUser('Customer Community Plus User','applicantuser@test.com',conList[0].Id);
        System.runAs(new User(Id = Userinfo.getUserId())) {
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ESRI_Community'];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        }
        system.runAs(usr) {
        	List<RegulatoryAuthorizationType> reglAuthTypeList = TestDataFactory.createReglAuthTypes(1,true,'event','License');
        	List<BusinessLicense> blList = TestDataFactory.createBusinessLicenses(1, true, 'test', reglAuthTypeList[0].Id);
            List<BusinessLicenseApplication> blaList = TestDataFactory.createBlas(1,true,'Event',reglAuthTypeList[0].Id);
            List<Schema.Location> locationList = TestDataFactory.createLocations(1,true,'Loc-01','Site',-79,43);
            List<AuthApplicationPlace> authAppPlaceList = TestDataFactory.createAuthApplicationPlaces(1,true,blaList[0].Id,locationList[0].Id);
            List<AuthLocationAccessSchedule> authLocAccSchList = TestDataFactory.createAuthLocSchedules(1,true,authAppPlaceList[0].Id,Date.today(),System.now().time(),Date.today()+1,System.now().time());
            String polygonData = '{"spatialReference":{"latestWkid":3857,"wkid":102100},"rings":[[[-8848674.650861043,5422584.950330664],[-8848567.209164083,5422623.168844808],[-8848536.90499061,5422510.105716169],[-8848648.479060533,5422467.109887757],[-8848674.650861043,5422584.950330664]]]}';
            List<Polygon> polygonList = TestDataFactory.createPolygons(1,true,'PolyRecd','GEOJSON',polygonData);
            List<Polygon_Schedule__c> psList = TestDataFactory.createPolygonSchedules(2,false,'PS-01',polygonList[0].Id,authLocAccSchList[0].Id);
            psList[0].Business_License__c = blList[0].Id;
            psList[1].Business_License__c = blList[0].Id;
            psList[0].Status__c = 'Approved';
            psList[1].Status__c = 'Approved';
            insert psList;
        }
    }
    
    @isTest
    private static void getLocationchedulesTest() {
        User usr = [SELECT Id FROM User where username = 'applicantuser@test.com'];
        System.runAs(usr) {
            Test.startTest();
                BusinessLicense bl = [SELECT Id FROM BusinessLicense LIMIT 1];
                List<String> result = Applicant_License_Approved_Ctr.getLocationchedules(bl.Id);
                System.Assert(result.size() > 0);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void unitTest() {
        User usr = [SELECT Id FROM User where username = 'applicantuser@test.com'];
        System.runAs(usr) {
            Test.startTest();
            	AuthLocationAccessSchedule authLocScheduleList = [SELECT Id FROM AuthLocationAccessSchedule LIMIT 1];
            
                PageReference pageRef = Page.Applicant_License_Approved_Page;
                pageRef.getParameters().put('authLocationId', String.valueOf(authLocScheduleList.Id));
                Test.setCurrentPage(pageRef);
            
                Applicant_License_Approved_Ctr obj = new Applicant_License_Approved_Ctr();
            	System.Assert(obj.strCurPolyRec != NULL);
            	System.Assert(obj.strLatitude != NULL);
            Test.stopTest();
        }
    }
}