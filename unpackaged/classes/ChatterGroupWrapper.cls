public with sharing class ChatterGroupWrapper{

    @AuraEnabled
    public Boolean Selected;
    @AuraEnabled
    public String Id;
    @AuraEnabled
    public String Name;
    @AuraEnabled
    public String Description;

    public ChatterGroupWrapper(Boolean Selected, String Id, String Name, String Description) {
        this.Selected = Selected;
        this.Id = Id;
        this.Name = Name;
        this.Description = Description;
    }

}