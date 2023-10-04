/**
 * Author : CSA
 * A pretty straight forward test class for ensuring that queue is getting
 * inserted after the installation of package
 */
@isTest
public class Pckg_PostInstall_Cls_Test{
    @isTest
    static void testInstallScript() {
        Pckg_PostInstall_Cls postinstall = new Pckg_PostInstall_Cls();
        Test.testInstall(postinstall, null);
        List<Group> lstGrp = [Select id, name from group where name ='Reviewers'];
        System.assert(!lstGrp.isEmpty());
    }
}