public with sharing class TemplateWrapper {
        @AuraEnabled public Id id {get; set;}
        @AuraEnabled public String name {get; set;}

        public TemplateWrapper() {}
        public TemplateWrapper(EmailTemplate et) {
            id = et.Id;
            name = et.Name;
        }
}