public with sharing class InternationalLocatorController {
  public String baseLocation {get; set;}
  public List<ResultSection> resultSections {get; private set;}
  public List<SelectOption> countries { get; set; }
  public Boolean searched {get; private set;}
  public Boolean empty { get{return (resultSections == null) || (resultSections.size() == 0);} }
  
  public InternationalLocatorController() {
    searched = false;
    
    countries = new List<SelectOption>();
    
    countries.add( new SelectOption('Argentina', 'Argentina') );
    countries.add( new SelectOption('Australia', 'Australia') );
    countries.add( new SelectOption('Austria', 'Austria') );
    countries.add( new SelectOption('Canada', 'Canada') );
    countries.add( new SelectOption('Czech Republic', 'Czech Republic') );
    countries.add( new SelectOption('France', 'France') );
    countries.add( new SelectOption('Germany', 'Germany') );
    countries.add( new SelectOption('Greece', 'Greece') );
    countries.add( new SelectOption('Ireland', 'Ireland') );
    countries.add( new SelectOption('Israel', 'Israel') );
    countries.add( new SelectOption('Italy', 'Italy') );
    countries.add( new SelectOption('Jordan', 'Jordan') );
    countries.add( new SelectOption('Netherlands', 'Netherlands') );
    countries.add( new SelectOption('New Zealand', 'New Zealand') );
    countries.add( new SelectOption('Nordic', 'Nordic') );
    countries.add( new SelectOption('Portugal', 'Portugal') );
    countries.add( new SelectOption('Puerto Rico', 'Puerto Rico') );
    countries.add( new SelectOption('Serbia', 'Serbia') );
    countries.add( new SelectOption('Switzerland', 'Switzerland') );
    countries.add( new SelectOption('Turkey', 'Turkey') );
    countries.add( new SelectOption('United Kingdom', 'United Kingdom') );
  }
  
  public PageReference onSearch() {
    if (StringUtils.isBlank(baseLocation)) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must enter a base country name'));
      return null;
    }
    
    resultSections = new List<ResultSection>();
    Map<String,ResultSection> resultSectionsMap = new Map<String,ResultSection>();
    
    try {
      //List<SObject> records = SearchService.getInstance().findRecords(baseLocation);
      List<Contact> contacts = [SELECT Name, Salutation, MailingStreet, MailingCity, MailingState, MailingPostalCode, Phone, Account.Name, Website__c, Picture__c
            FROM Contact WHERE Adoption_Status__c = 'Ablating' AND Physician_Locator__c = true AND MailingCountry = :baseLocation limit 400];
            
      for (Contact contact : contacts) {
        ResultSection resultSection = resultSectionsMap.get( contact.MailingCity );    
        if( resultSection == null ) {
          resultSection = new ResultSection(new List<ResultRow>(), contact.MailingCity);
              
          resultSectionsMap.put(contact.MailingCity, resultSection);
        }
        
        resultSection.resultRows.add( new ResultRow(contact, contact.Name) );
      }
      
      resultSections = resultSectionsMap.values();
      
      CollectionUtils.sort(resultSections);
      
      for( ResultSection resultSection : resultSections ) {
        CollectionUtils.sort( resultSection.resultRows );
      }
    } catch (Exception e) {
      ApexPages.addMessages(e);
      return null;
    }
    searched = true;
    return null;
  }
  
  public class ResultSection implements CollectionUtils.Comparable {
    public List<ResultRow> resultRows {get; private set;}
    public String cityName {get; private set;}
    
    public ResultSection(List<ResultRow> resultRows, String cityName) {
      this.resultRows = resultRows;
      this.cityName = cityName;
    }
    
    public Integer compareTo(Object value) {
      ResultSection other = (ResultSection)value;
      
      String otherValue = other.cityName != null ? other.cityName : '';
        String thisValue = this.cityName != null ? this.cityName : '';
        
      return thisValue.compareTo(otherValue);
    }
  }
  
  public class ResultRow implements CollectionUtils.Comparable {
    public SObject record {get; private set;}
    public String physicianName {get; private set;}
    public Contact contact {get{return (Contact)record;}}
    
    public ResultRow(SObject record, String physicianName) {
      this.record = record;
      this.physicianName = physicianName;
    }
    
    public Integer compareTo(Object value) {
      ResultRow other = (ResultRow)value;
      
      String otherValue = other.physicianName != null ? other.physicianName : '';
        String thisValue = this.physicianName != null ? this.physicianName : '';
        
      return thisValue.compareTo(otherValue);
    }
  }
}