/**
 * Author : CSA
 * @description This class is used for inserting a queue after installation of the package.
 * Queue insertion happens only during the first installation of the package and if the User 
 * is unable to see creation of queue post installation they can execute
 * insertQueue method from anonymous block of developer console
 */
global without sharing class Pckg_PostInstall_Cls implements InstallHandler {
    global void onInstall(InstallContext context) {
        //Below condition to ensure that the class executes only after first time of installation
        if(context.previousVersion() == null) {
            insertQueue();
        }
    }
    
    public static void insertQueue(){
        //Insert a queue after installation
        Group g1 = new Group(Name='Reviewers', type='Queue');
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, new List<Group>{g1});
        insert securityDecision.getRecords();
        Id insertedGrpId = securityDecision.getRecords()[0].Id;
        QueuesObject q1 = new QueueSObject(QueueID = insertedGrpId, SobjectType = 'BusinessLicenseApplication');
        securityDecision = Security.stripInaccessible(AccessType.CREATABLE, new List<QueuesObject>{q1});
        insert securityDecision.getRecords();
    }
}
