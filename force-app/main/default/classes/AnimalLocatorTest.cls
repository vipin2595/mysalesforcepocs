@istest
public class AnimalLocatorTest {
    
    @istest static void testcallout(){
        test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        string result = AnimalLocator.getAnimalNameById(1);
    }

}