public with sharing class CustomField {
    @AuraEnabled public String name { get; set; }
    @AuraEnabled public String value { get; set; }
    @AuraEnabled public String label { get; set; }
    @AuraEnabled public String fieldType { get; set; }

    public CustomField(String name, String value, String fieldType) {
        this.name = name;
        this.value = value;
        this.fieldType = fieldType;
    }

    public CustomField(String name, String value, String fieldType, String label) {
        this.name = name;
        this.value = value;
        this.label = label;
        this.fieldType = fieldType;
    }
}