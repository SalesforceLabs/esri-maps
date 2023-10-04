@isTest
public class Reviewer_Approval_CtrTest {
    @TestSetup
    static void setupData() {
        List<RegulatoryAuthorizationType> reglAuthTypeList = TestDataFactory.createReglAuthTypes(1,true,'event','License');
        List<BusinessLicenseApplication> blaList = TestDataFactory.createBlas(1,true,'Event',reglAuthTypeList[0].Id);
        List<Schema.Location> locationList = TestDataFactory.createLocations(1,true,'Loc-01','Site',-79,43);
        List<AuthApplicationPlace> authAppPlaceList = TestDataFactory.createAuthApplicationPlaces(1,true,blaList[0].Id,locationList[0].Id);
        List<AuthLocationAccessSchedule> authLocAccSchList = TestDataFactory.createAuthLocSchedules(1,true,authAppPlaceList[0].Id,Date.today(),System.now().time(),Date.today()+1,System.now().time());
        String polygonData = '{"spatialReference":{"latestWkid":3857,"wkid":102100},"rings":[[[-8848674.650861043,5422584.950330664],[-8848567.209164083,5422623.168844808],[-8848536.90499061,5422510.105716169],[-8848648.479060533,5422467.109887757],[-8848674.650861043,5422584.950330664]]]}';
        List<Polygon> polygonList = TestDataFactory.createPolygons(1,true,'PolyRecd','GEOJSON',polygonData);
        List<Polygon_Schedule__c> psList = TestDataFactory.createPolygonSchedules(2,true,'PS-01',polygonList[0].Id,authLocAccSchList[0].Id);
        List<Task> taskList = TestDataFactory.createTasks(1,true,'Map Review', blaList[0].Id, 'Not Started');
    }
    
    @isTest
    private static void unitTest() {
        Test.startTest();
            Polygon_Schedule__c ps = [SELECT Id FROM Polygon_Schedule__c LIMIT 1];
        
            PageReference pageRef = Page.Reviewer_Approval_Page;
            pageRef.getParameters().put('polySchId', String.valueOf(ps.Id));
            Test.setCurrentPage(pageRef);
        
        	Reviewer_Approval_Ctr obj = new Reviewer_Approval_Ctr();
       	 	obj.strData = '{"spatialReference":{"latestWkid":3857,"wkid":102100},"rings":[[[-8888888.650861043,9999999.950330664],[-8848567.209164083,5422623.168844808],[-8848536.90499061,5422510.105716169],[-8848648.479060533,5422467.109887757],[-8848674.650861043,5422584.950330664]]]}';
        	obj.updatePolygon();
        	System.Assert(obj.strPolygonUpdStatus == 'Update succesful');
        	System.Assert(obj.strCurPolyRec != null);
        	System.Assert(obj.strRelatedPolyRecs != null);
        Test.stopTest();
    }
    
    @isTest
    private static void updateScheduleStatusTest() {
        Test.startTest();	
        	Polygon_Schedule__c ps = [SELECT Id FROM Polygon_Schedule__c LIMIT 1];
        	Reviewer_Approval_Ctr.updateScheduleStatus(ps.Id, 'Approved');
        	System.Assert([SELECT Id, Status__c FROM Polygon_Schedule__c WHERE Id =: ps.Id].Status__c == 'Approved');
        Test.stopTest();
    }
    
    @isTest
    private static void getPolySchdulesTest() {
        Test.startTest();	
        	Task t = [SELECT Id FROM Task LIMIT 1];
        	List<Polygon_Schedule__c> psList = Reviewer_Approval_Ctr.getPolySchdules(t.Id);
        	System.Assert(psList.size() > 0);
        Test.stopTest();
    }
    
    
}