/**
 * Custom business logic to perform searches for records that match
 * requested locations.
 * 
 * @author Max Rudman
 * @since 8/16/2010
 */
public with sharing class SearchService {
    public static final SearchService INSTANCE = new SearchService();
    
    public static SearchService getInstance() {
        return INSTANCE;
    } 
    
    public List<SObject> findRecords(Set<String> locations, Map<String,String> filters) {
       /*return [SELECT Name, Salutation, MailingStreet, MailingCity, MailingState, 
                    MailingPostalCode, Phone, Account.Name, Website__c, Picture__c, LastName
                FROM Contact
                WHERE MailingPostalCode IN :locations AND Adoption_Status__c = 'Ablating' AND Physician_Locator__c = true 
                    AND ( MailingCountry = 'United States' OR MailingCountry = 'US' OR MailingCountry = 'USA' OR MailingCountry =  'United States of America' OR MailingCountry =  '' ) ];*/
                    
       //condition according to T-
       String contactType = 'Practicing Physician';
       return [SELECT Name, Salutation, MailingStreet, MailingCity, MailingState, 
                    MailingPostalCode, Phone, Account.Name, Website__c, Picture__c, LastName,Ablating__c
                FROM Contact
                WHERE MailingPostalCode IN :locations AND RFA_Status__c = 'Ablate' AND Physician_Locator__c = true AND RFA_Indications__c != null AND RFA_Indications__c != 'N/A' AND RecordType.Name  = :contactType 
                    AND ( MailingCountry = 'United States' OR MailingCountry = 'US' OR MailingCountry = 'USA' OR MailingCountry =  'United States of America' OR MailingCountry =  '' ) ];       
    }
}