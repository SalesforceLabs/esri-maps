@isTest
public class CreateEsriCustomerUserHandlerTest {
    @testSetup
    static void setupData() {
        List<Account> accList = TestDataFactory.createAccounts(1, true, 'test');
        List<Contact> conList = TestDataFactory.createContacts(1, true, 'test last name', accList[0].Id);
    }
   
    @isTest
    private static void createUserTest() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        String profileId = [SELECT Id,Name FROM profile WHERE Name = 'Customer Community User'].Id;
        Schema.SobjectField contactId = Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap().get('ContactId');
        Test.startTest();
        CreateEsriCustomerUserHandler controller = new CreateEsriCustomerUserHandler();
        Map<SObjectField,String> registrationAttributes = new Map<SObjectField,String>();
        registrationAttributes.put(contactId,con.Id);
        Id guestUserId = controller.createUser(acc.Id, profileId, registrationAttributes, '');
        system.assertNotEquals(guestUserId, null);
        Test.stopTest();
    }
}