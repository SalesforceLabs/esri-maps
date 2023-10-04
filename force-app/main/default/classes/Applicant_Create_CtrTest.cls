// Test class for Applicant_Create_Ctr
@isTest
public class Applicant_Create_CtrTest {
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
            List<BusinessLicenseApplication> blaList = TestDataFactory.createBlas(1,true,'Event',reglAuthTypeList[0].Id);
            List<Schema.Location> locationList = TestDataFactory.createLocations(1,true,'Loc-01','Site',-79,43);
            List<AuthApplicationPlace> authAppPlaceList = TestDataFactory.createAuthApplicationPlaces(1,true,blaList[0].Id,locationList[0].Id);
            List<AuthLocationAccessSchedule> authLocAccSchList = TestDataFactory.createAuthLocSchedules(2,true,authAppPlaceList[0].Id,Date.today(),System.now().time(),Date.today()+1,System.now().time());
            String polygonData = '{"spatialReference":{"latestWkid":3857,"wkid":102100},"rings":[[[-8848674.650861043,5422584.950330664],[-8848567.209164083,5422623.168844808],[-8848536.90499061,5422510.105716169],[-8848648.479060533,5422467.109887757],[-8848674.650861043,5422584.950330664]]]}';
            List<Polygon> polygonList = TestDataFactory.createPolygons(1,true,'PolyRecd','GEOJSON',polygonData);
            List<Polygon_Schedule__c> psList = TestDataFactory.createPolygonSchedules(1,true,'PS-01',polygonList[0].Id,authLocAccSchList[0].Id);
        }
    }
    
    @isTest
    private static void unitTest() {
        Map<String,Object> schDetails = new Map<String,Object>();
        schDetails.put('strtDate',Date.today());
        schDetails.put('strtTime',System.now().time());
        schDetails.put('endDate',Date.today()+1);
        schDetails.put('endTime',System.now().time());
        User usr = [SELECT Id FROM User where username = 'applicantuser@test.com'];
        System.runAs(usr) {
            Test.startTest();
                Applicant_Create_Ctr obj = new Applicant_Create_Ctr();
                obj.schDetails = JSON.serialize(schDetails);
                obj.fetchTimeDetails();
                system.assert(obj.allPolygons != null);
            Test.stopTest();
        }
    }
}